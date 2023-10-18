//
//  FeatureSearchViewController.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/19.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
import Core
import NetworkService
import UI
import Utils

public class FeatureSearchViewController: UIViewController {
    private var cancellabels = Set<AnyCancellable>()
    private var resultViewModel = FeatureSearchResultViewModel(searchResults: iTuensDataResponseModel(from: nil))
    
    private lazy var resultController = FeatureSearchResultViewController(navigationController: navigationController, viewModel: resultViewModel)
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultController)
        
        controller.searchBar.searchButtonClickedPublisher.sink { [weak self] _ in
            self?.searchValueSubject.send(controller.searchBar.text ?? "")
        }.store(in: &cancellabels)
        
        controller.searchBar.searchTextField.didBeginEditingPublisher
            .sink { [weak self] _ in
            NotificationCenter.default.post(name: .startSearch, object: self)
        }.store(in: &cancellabels)
        
        controller.searchBar.cancelButtonClickedPublisher.sink { [weak self] _ in
            NotificationCenter.default.post(name: .endSearch, object: self)
            self?.tableView.reloadData()
        }.store(in: &cancellabels)
        
        return controller
    }()
    private lazy var searchValueSubject: PassthroughSubject<String, Never> = .init()
    
    private let titleLabel: UILabel = UILabelFactory.build(text: "검색", font: AppStoreFont.bold(ofSize: AppStoreSize.titleSize))
    private lazy var profileIcon: UIButton = {
        let button = UIButtonFactory.build(image: UIImage(systemName: "person.crop.circle"))
        return button
    }()
    
    private lazy var titleView: UIStackView = {
        let widthSpacer = DividerFactory.build(width: CGFloat.greatestFiniteMagnitude)
        let contentView = UIStackView(
            arrangedSubviews: [titleLabel, widthSpacer, profileIcon]
        )
        contentView.axis = .horizontal
        
        return contentView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        settingSearchController()
        layout()
        bind()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func layout() {
        self.view.backgroundColor = UIAsset.white.color
        view.addSubview(tableView)
        
        if let profileIcon = profileIcon.imageView {
            profileIcon.snp.makeConstraints { make in
                make.height.equalTo(AppStoreSize.titleSize)
                make.width.equalTo(profileIcon.snp.height)
            }
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(AppStoreSize.defaultPadding)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-AppStoreSize.defaultPadding)
            make.bottom.equalToSuperview().offset(-AppStoreSize.defaultPadding)
        }
    }
    
    func bind() {
        self.resultController.viewDidLoad()
        
        let pagingPublisher = Publishers.Merge(
            NotificationCenter.default.publisher(for: .searchAppPagingTriggered),
            NotificationCenter.default.publisher(for: .enterSearch)
        )
            .map { [weak self] _ in
                self?.searchController.searchBar.text = self?.resultViewModel.currentTerm ?? ""
                return self?.resultViewModel.currentTerm ?? ""
            }
            .eraseToAnyPublisher()
        
        let tableCellSelectedPublisher = tableView.didSelectRowPublisher
            .map { [weak self] index in
                let term = self?.resultViewModel.histories[index.item - 1 == -1 ? 0 : index.item - 1] ?? ""
                NotificationCenter.default.post(name: .startSearch, object: self)
                DispatchQueue.main.async {
                    self?.tableView.deselectRow(at: index, animated: true)
                    self?.searchController.searchBar.text = term
                    self?.searchController.isActive = true
                    self?.searchController.showsSearchResultsController = true
                }
                return term
            }
            .eraseToAnyPublisher()
        
        let searchResultPublisher = Publishers.Merge3(searchClickedValuePublisher, pagingPublisher, tableCellSelectedPublisher)
            .eraseToAnyPublisher()        
        
        let input = FeatureSearchResultViewModel.Input(
            searchHistoryPublisher: searchController.searchBar.textDidChangePublisher,
            searchResultPublisher: searchResultPublisher,
            searchCancelPublisher: searchController.searchBar.cancelButtonClickedPublisher,
            userButtonTapPublisher: profileIcon.tapPublisher
        )
        
        let output = resultViewModel.transform(input: input)
        
        output.historyPublisher.sink { item in
            self.resultController.reloadHistorySnapshot(history: item)
        }.store(in: &cancellabels)
        
        output.fetchAppPublisher.sink { status in
            switch status {
            case .finished: break
            case .failure(let error): print(error)
            }
        } receiveValue: { [weak self] value in
            self?.resultController.reloadResultSnapshot(searchResult: self?.resultViewModel.searchResults.compactMap { DataSourceItem.searchResult($0) } ?? [])
        }.store(in: &cancellabels)
        
        output.cancelPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.resultViewModel.searchResults = []
            }.store(in: &cancellabels)
        
        output.userPublisher.sink { _ in
        }.store(in: &cancellabels)
    }
    
    private func settingSearchController() {
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.placeholder = "게임, 앱, 스토리 등"
        
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = false
        
        navigationItem.searchController = searchController
        navigationItem.titleView = titleView
    }
}

extension FeatureSearchViewController {
    private var searchClickedValuePublisher: AnyPublisher<String, Never> {
        return Publishers
            .Zip(searchValueSubject, searchController.searchBar.searchButtonClickedPublisher)
            .map { term, _ in
                return term
            }
            .eraseToAnyPublisher()
    }
}

extension FeatureSearchViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let history = UserDefaults.standard.array(forKey: UserDefaultsKeys.searchHistory.rawValue)
        return history?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let history = UserDefaults.standard.array(forKey: UserDefaultsKeys.searchHistory.rawValue) as? [String] ?? [String]().reversed()

        // Configure content.
        content.attributedText = NSAttributedString(
            string: history[indexPath.row],
            attributes: [.font: indexPath.row == 0 ? AppStoreFont.bold(ofSize: AppStoreSize.contentSize) : AppStoreFont.regular(ofSize: AppStoreSize.contentSize),
                         .foregroundColor: indexPath.row == 0 ? UIAsset.fontBlack.color : UIAsset.mainBlue.color
            ]
        )
        content.textProperties.numberOfLines = 1
        content.textProperties.lineBreakMode = .byTruncatingTail
        
        cell.contentConfiguration = content
        
        if indexPath.row == 0 || indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 10, left: AppStoreSize.defaultPadding, bottom: 10, right: AppStoreSize.defaultPadding)
        }
        
        return cell
    }
}
