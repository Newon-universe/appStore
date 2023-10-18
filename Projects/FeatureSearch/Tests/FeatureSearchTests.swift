//
//  FeatureSearchTests.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import Foundation
import FeatureSearch
import NetworkService
import Utils
import Combine
import XCTest

final class FeatureSearchTests: XCTestCase {
    
    private var cancellabels = Set<AnyCancellable>()
    let textChangePublisher = PassthroughSubject<String, Never>()
    let searchResultPublisher = PassthroughSubject<String, Never>()
    let searchCancelPublisher = PassthroughSubject<Void, Never>()
    let userButtonTapPublisher = PassthroughSubject<Void, Never>()
    
    
    func test_NetworkFetchApp() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch App Expectation")
        let endpoint = Endpoint.fetchApp(term: "Apple")

        // When
        NetworkService<iTuensDataResponseModel>.fetchApp(with: endpoint) { result in
            switch result {
            case .success(let response):
                // Then
                print("Response received:")
                print(response)
                XCTAssertGreaterThan(response.resultCount ?? 0, 0)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error: \(error)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_ViewModel_fetchApp() {
        let resultViewModel = FeatureSearchResultViewModel(searchResults: iTuensDataResponseModel(from: nil))

        let input = FeatureSearchResultViewModel.Input(
            searchHistoryPublisher: textChangePublisher.eraseToAnyPublisher(),
            searchResultPublisher: searchResultPublisher.eraseToAnyPublisher(),
            searchCancelPublisher: searchCancelPublisher.eraseToAnyPublisher(),
            userButtonTapPublisher: userButtonTapPublisher.eraseToAnyPublisher()
        )
        
        // given
        let expectation = XCTestExpectation(description: "Fetch App from ViewModel Expectation")
        let output = resultViewModel.transform(input: input)
        var testValue: iTuensDataResponseModel? = nil
        output.fetchAppPublisher.sink { status in
            switch status {
            case .finished: break
            case .failure(let error): print(error)
            }
        } receiveValue: { value in
            expectation.fulfill()
            testValue = value
        }.store(in: &cancellabels)
        
        // when
        searchResultPublisher.send("Apple")

        // then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(testValue?.results?.count, 10)
    }
    
    
    func test_ViewModel_historyCheck() {
        let resultViewModel = FeatureSearchResultViewModel(searchResults: iTuensDataResponseModel(from: nil))

        let input = FeatureSearchResultViewModel.Input(
            searchHistoryPublisher: textChangePublisher.eraseToAnyPublisher(),
            searchResultPublisher: searchResultPublisher.eraseToAnyPublisher(),
            searchCancelPublisher: searchCancelPublisher.eraseToAnyPublisher(),
            userButtonTapPublisher: userButtonTapPublisher.eraseToAnyPublisher()
        )
        
        var output = resultViewModel.transform(input: input)
        
        // given
        let expectation = XCTestExpectation(description: "history check from ViewModel Expectation")
        var testValue: [History]? = nil
        output.historyPublisher.sink { items in
            let histories = items.compactMap { item -> History? in
                if case .searchHistory(let model) = item {
                    return model
                }
                return nil
            }
            
            expectation.fulfill()
            testValue = histories
        }.store(in: &cancellabels)
        
        // when
        searchResultPublisher.send("Apple")
        textChangePublisher.send("pp")
        
        // then
        wait(for: [expectation], timeout: 5.0)
        let checkValue = testValue?.filter { $0.title == "Apple" }.map { $0.title }
        XCTAssertEqual(checkValue?.count, 1)
        XCTAssertEqual(checkValue?.first, "Apple")
    }

    func test_example() {
        XCTAssertEqual("FeatureSearchTests", "FeatureSearchTests")
    }
}
