//
//  FeatureSearchResultViewModel.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/21.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation
import Combine
import Core
import NetworkService
import Utils

public final class FeatureSearchResultViewModel: ObservableObject {
    
    private var urlCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = 100
        return cache
    }()
    
    public struct Input {
        let searchHistoryPublisher: AnyPublisher<String, Never>
        let searchResultPublisher: AnyPublisher<String, Never>
        let searchCancelPublisher: AnyPublisher<Void, Never>
        let userButtonTapPublisher: AnyPublisher<Void, Never>
        
        public init(searchHistoryPublisher: AnyPublisher<String, Never>, searchResultPublisher: AnyPublisher<String, Never>, searchCancelPublisher: AnyPublisher<Void, Never>, userButtonTapPublisher: AnyPublisher<Void, Never>) {
            self.searchHistoryPublisher = searchHistoryPublisher
            self.searchResultPublisher = searchResultPublisher
            self.searchCancelPublisher = searchCancelPublisher
            self.userButtonTapPublisher = userButtonTapPublisher
        }
    }
    
    public struct Output {
        public let historyPublisher: AnyPublisher<[DataSourceItem], Never>
        public let fetchAppPublisher: AnyPublisher<iTuensDataResponseModel, NetworkServiceError>
        public let cancelPublisher: AnyPublisher<Void, Never>
        public let userPublisher: AnyPublisher<Void, Never>
        
        public init(historyPublisher: AnyPublisher<[DataSourceItem], Never>, fetchAppPublisher: AnyPublisher<iTuensDataResponseModel, NetworkServiceError>, cancelPublisher: AnyPublisher<Void, Never>, userPublisher: AnyPublisher<Void, Never>) {
            self.historyPublisher = historyPublisher
            self.fetchAppPublisher = fetchAppPublisher
            self.cancelPublisher = cancelPublisher
            self.userPublisher = userPublisher
        }
    }
    
    private var cancellabels = Set<AnyCancellable>()
    @Published public var searchResults: [iTuensModel]
    var currentTerm: String? = nil
    
    public var isPagination = false
    
    public var histories: [String] {
        get {
            (UserDefaults.standard.array(forKey: UserDefaultsKeys.searchHistory.rawValue)?.tail as? [String] ?? [String]())
        }
        set {
            guard var history = UserDefaults.standard.array(forKey: UserDefaultsKeys.searchHistory.rawValue) as? [String],
                  let newValue = newValue.first,
                  !history.contains(newValue)
            else { return }

            if history.count > 10 { history.remove(at: 1) }
            history.append(newValue)
            UserDefaults.standard.set(history, forKey: UserDefaultsKeys.searchHistory.rawValue)
        }
    }
    
    
    public init(searchResults: iTuensDataResponseModel) {
        self.searchResults = searchResults.results ?? []
        
        if UserDefaults.standard.array(forKey: UserDefaultsKeys.searchHistory.rawValue) as? [String] ?? [String]() == [String]() {
            var history = UserDefaults.standard.array(forKey: UserDefaultsKeys.searchHistory.rawValue) as? [String] ?? [String]()
            history.append("최근 검색어")
            UserDefaults.standard.set(history, forKey: UserDefaultsKeys.searchHistory.rawValue)
        }
    }
    
    public func transform(input: Input) -> Output {
        
        let searchHistoryPublisher = input.searchHistoryPublisher
            .flatMap { [unowned self] searchText in
                self.currentTerm = searchText
                return Just(historiesFilter(term: searchText).compactMap { DataSourceItem.searchHistory(History(title: $0)) } )
            }
            .eraseToAnyPublisher()
        
        let searchResultsPublisher = input.searchResultPublisher
            .flatMap { [unowned self] term in
                currentTerm = term
                return Future<iTuensDataResponseModel, NetworkServiceError> { promise in
                    Task {
                        if let data = self.urlCache.object(forKey: term as AnyObject) as? iTuensDataResponseModel {
                            promise(.success(data))
                        } else {
                            let data = await self.fetchAppAsync(for: term)
                            switch data {
                            case .success(let response):
                                self.histories = [term]
                                self.searchResults += response.results ?? []
                                promise(.success(response))
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
                
        let userButtonTapPublisher = input.userButtonTapPublisher.handleEvents(receiveOutput: { _ in
            print("user button clicked")
        }).flatMap {
            return Just($0)
        }.eraseToAnyPublisher()
        
        return Output(
            historyPublisher: searchHistoryPublisher,
            fetchAppPublisher: searchResultsPublisher,
            cancelPublisher: input.searchCancelPublisher,
            userPublisher: userButtonTapPublisher
        )
    }
    
    public func historiesFilter(term: String) -> [String] {
        let item = histories.compactMap {
            $0.lowercased().hasPrefix(term.lowercased()) ? $0 : 
            $0.lowercased().hasSuffix(term.lowercased()) ? $0 :
            $0.lowercased().contains(term.lowercased()) ? $0 : nil
        }
        
        return item
    }
    
    //MARK: - fetchApp...() 기능들은 네트워크 동일한 기능, 다르게 적용
    // fetchApp() -> Completion 사용
    // fetchAppCombine() -> Combine 사용
    // fetchAppAsync() -> async, Result 사용
    
    public func fetchApp(for searchTerm: String) {
        guard searchResults.count % 10 == 0 else { return }
        currentTerm = searchTerm
        
        DispatchQueue.main.async { self.isPagination = true }
        NetworkService<iTuensDataResponseModel>.fetchApp(with: Endpoint.fetchApp(term: searchTerm, offset: searchResults.count)) { result in
            switch result {
            case .success(let response): DispatchQueue.main.async { self.searchResults += response.results ?? [] }
            case .failure(let error): print(error)
            }
            self.isPagination = false
        }
    }
    
    public func fetchAppCombine(for searchTerm: String) {
        guard searchResults.count % 10 == 0 else { return }
        currentTerm = searchTerm
        
        DispatchQueue.main.async { self.isPagination = true }
        NetworkService<iTuensDataResponseModel>.fetchAppWithCombine(with: .fetchApp(term: searchTerm, offset: searchResults.count))
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { data in
                self.searchResults += data.results ?? []
                DispatchQueue.main.async { self.isPagination = false }
            }
            .store(in: &cancellabels)
    }
    
    public func fetchAppAsync(for searchTerm: String) {
        guard searchResults.count % 10 == 0 else { return }
        currentTerm = searchTerm
        
        DispatchQueue.main.async { self.isPagination = true }
        
        Task {
            let result = await NetworkService<iTuensDataResponseModel>.fetchAppWithAsync(with: .fetchApp(term: searchTerm, offset: searchResults.count))
            switch result {
            case .success(let data): self.searchResults += data.results ?? []
            case .failure(let error): print(error)
            }
            
            DispatchQueue.main.async { self.isPagination = false }
        }
    }
    
    public func fetchAppAsync(for searchTerm: String) async -> Result<iTuensDataResponseModel, NetworkServiceError>{
        guard searchResults.count % 10 == 0 else { return .failure(.serverError("No results")) }
        currentTerm = searchTerm
        
        DispatchQueue.main.async { self.isPagination = true }
        
        let result = await NetworkService<iTuensDataResponseModel>.fetchAppWithAsync(with: .fetchApp(term: searchTerm, offset: searchResults.count))
        
        DispatchQueue.main.async { self.isPagination = false }
        
        switch result {
        case .success(let data): return .success(data)
        case .failure(let error): return .failure(error)
        }
    }
}
