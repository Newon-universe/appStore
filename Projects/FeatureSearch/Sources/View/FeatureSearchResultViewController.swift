//
//  FeatureSearchResultViewController.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import Core
import UI
import Utils

public class FeatureSearchResultViewController: UICollectionViewController {
    private weak var featureNavigaionController: UINavigationController?
    private weak var viewModel: FeatureSearchResultViewModel?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, DataSourceItem>!
    
    public enum Section: Int, CaseIterable {
        case history
        case result
    }
    
    private var cancellabels = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController?, viewModel: FeatureSearchResultViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: FeatureSearchResultViewController.setupCompositionalLayout())
        self.featureNavigaionController = navigationController
    }
    
    public override func viewDidLoad() {
        setupCollectionViewController()
        setupDataSource()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadHistorySnapshot(history items: [DataSourceItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()
        snapshot.appendSections([.history, .result])
        snapshot.appendItems(items, toSection: .history)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func reloadResultSnapshot(searchResult items: [DataSourceItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()
        snapshot.appendSections([.history, .result])
        snapshot.appendItems(items, toSection: .result)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
}


//MARK: - CollectionView Setup functions
extension FeatureSearchResultViewController {
    
    func setupCollectionViewController() {
        collectionView.register(
            SearchCollectionHistoryCell.self,
              forCellWithReuseIdentifier: SearchCollectionHistoryCell.identifier
        )
        
        collectionView.register(
              SearchCollectionResultCell.self,
              forCellWithReuseIdentifier: SearchCollectionResultCell.identifier
        )
    }
    
    func setupDataSource() {
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
            
            switch section {
            case .history:
                if case .searchHistory(let history) = item {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: SearchCollectionHistoryCell.identifier,
                        for: indexPath
                    ) as! SearchCollectionHistoryCell
                    
                    cell.configure(item: history.title)
                    
                    return cell
                }
                
            case .result:
                if case .searchResult(let iTunesModel) = item {
                            let cell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: SearchCollectionResultCell.identifier,
                                for: indexPath
                            ) as! SearchCollectionResultCell
                            
                            cell.configure(item: iTunesModel)
                            return cell
                        }
            }
            return UICollectionViewCell()
        })
        
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, kind, indexPath) in
            guard let footerView = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: FooterIndicatorView.identifier,
                for: indexPath
            ) as? FooterIndicatorView else { fatalError() }
            
            footerView.toggleLoading(isEnabled: viewModel?.isPagination ?? false)
            return footerView
        }
        
        self.collectionView.dataSource = self.dataSource
    }
    
    static func setupCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, env in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .history:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(AppStoreSize.titleSize + AppStoreSize.defaultPadding)
                    ),
                    subitems: [item]
                )
                
                group.contentInsets = .init(top: AppStoreSize.defaultPadding, leading: AppStoreSize.defaultPadding, bottom: 0, trailing: 0)
                let section = NSCollectionLayoutSection(group: group)
                return section
                
            case .result:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(0.45)
                    ),
                    subitems: [item]
                )
                
                group.contentInsets = .init(top: AppStoreSize.defaultPadding, leading: AppStoreSize.defaultPadding, bottom: 5, trailing: AppStoreSize.defaultPadding)
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
        
        return layout
    }
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .history: return viewModel?.histories.count ?? 0
        case .result: return viewModel?.searchResults.count ?? 0
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .history:
            guard let viewModel = self.viewModel,
                  let term = viewModel.currentTerm
            else { return }
            let item = viewModel.historiesFilter(term: term)[indexPath.row]
            self.viewModel?.currentTerm = item
            NotificationCenter.default.post(name: .enterSearch, object: self)
            
        case .result:
            guard let item = self.viewModel?.searchResults[indexPath.row] else { return }
            let detailViewController = FeatureSearchDetailViewController(item: item)
            detailViewController.configure(item: item)
            
            self.featureNavigaionController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        guard let viewModel = viewModel else { return }
        
        switch section {
        case .history: break
        case .result:
            if indexPath.item == viewModel.searchResults.count - 1 {
                NotificationCenter.default.post(name: .searchAppPagingTriggered, object: self)
            }
        }
    }
}
