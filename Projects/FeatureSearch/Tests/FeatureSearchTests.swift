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
import XCTest

final class FeatureSearchTests: XCTestCase {
    
    func test_NetworkFetchApp() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch App Expectation")
        let endpoint = Endpoint.fetchApp(term: "헤이 딜러")

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
        
//        let input = FeatureSearchResultViewModel.Input(
//            searchHistoryPublisher: searchController.searchBar.textDidChangePublisher,
//            searchResultPublisher: searchResultPublisher,
//            searchCancelPublisher: searchController.searchBar.cancelButtonClickedPublisher,
//            userButtonTapPublisher: profileIcon.tapPublisher
//        )
//        
//        var output = resultViewModel.transform(input: input)
//        
//        output.historyPublisher.sink { item in
//            self.resultController.reloadHistorySnapshot(history: item)
//        }.store(in: &cancellabels)
//        
//        output.fetchAppPublisher.sink { status in
//            switch status {
//            case .finished: break
//            case .failure(let error): print(error)
//            }
//        } receiveValue: { [weak self] value in
//            self?.resultViewModel.searchResults += value.results ?? []
//            self?.resultController.reloadResultSnapshot(searchResult: self?.resultViewModel.searchResults.compactMap { DataSourceItem.searchResult($0) } ?? [])
//        }.store(in: &cancellabels)
//        
//        output.cancelPublisher
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.resultViewModel.searchResults = []
//            }.store(in: &cancellabels)
//        
//        output.userPublisher.sink { _ in
//        }.store(in: &cancellabels)
    }
    
    func test_example() {
        XCTAssertEqual("FeatureSearchTests", "FeatureSearchTests")
    }
}
