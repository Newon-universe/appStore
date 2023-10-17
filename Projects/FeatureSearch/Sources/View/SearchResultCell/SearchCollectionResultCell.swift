//
//  FeatureSearchResultCollectionViewCell.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import SnapKit
import Combine
import Core
import UIKit
import UI

enum ScreenshotEnum: CaseIterable {
    case main
}

struct AppScreenShot: Hashable {
    let image: String
    let identifier = UUID().uuidString
}

class SearchCollectionResultCell: UICollectionViewCell {
    static let identifier = CellIdentifier.searchResultCell.rawValue
    private var cancellabels = Set<AnyCancellable>()
    private var screenShots: [AppScreenShot] = []
    
    private var titleLabel = UILabelFactory.build(
        text: "",
        font: AppStoreFont.regular(ofSize: AppStoreSize.contentSize)
    )
    
    private var subTitleLabel = UILabelFactory.build(
        text: "",
        font: AppStoreFont.regular(ofSize: AppStoreSize.captionSize),
        textColor: UIAsset.fontSemiBlack.color
    )
    
    private lazy var ratingView: UIStackView = UIStackView()
        
    lazy var labelContainer: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [titleLabel, subTitleLabel, ratingView]
        )
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let activityIndicator = UIActivityIndicatorView()
    let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIAsset.backgroundGray.color
        imageView.addCornerRadius(radius: 12)
        
        imageView.layer.borderWidth = 0.2
        imageView.layer.borderColor = UIAsset.fontGray.color.cgColor
        return imageView
    }()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        let title = NSAttributedString(
            string: "받기",
            attributes: [
                .font: AppStoreFont.bold(ofSize: AppStoreSize.captionSize),
                .foregroundColor: UIAsset.mainBlue.color
            ]
        )
        
        button.setAttributedTitle(
            title,
            for: .normal
        )
        button.tintColor = UIAsset.mainBlue.color
        button.backgroundColor = UIAsset.backgroundGray.color
        button.addCornerRadius(radius: 13)
        
        // NotificationCenter 등으로 publisher 를 viewModel 까지 올려서
        // button action 을 받아올 수 있을 듯.
        button.tapPublisher
            .sink { _ in
                print("Search-Download button clicked")
            }
            .store(in: &self.cancellabels)
        
        return button
    }()
        
    private var screenShotCollectionView: UICollectionView!
    private var screenShotDataSource: UICollectionViewDiffableDataSource<ScreenshotEnum, AppScreenShot>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScreenShotCollectionViewController()
        layout()
        setupScreenShotDataSource()
        reloadScreenShotDataSource()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout(){
        backgroundColor = UIAsset.white.color
        
        [logoView, activityIndicator, labelContainer, downloadButton, screenShotCollectionView].forEach {
            addSubview($0)
        }
        
        logoView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(AppStoreSize.middleImageSize)
            make.width.equalTo(AppStoreSize.middleImageSize)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(logoView.snp.center)
            make.width.equalTo(AppStoreSize.titleSize)
            make.height.equalTo(AppStoreSize.titleSize)
        }
        
        labelContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(logoView.snp.bottom).offset(-2)
            make.leading.equalTo(logoView.snp.trailing).offset(10)
            make.trailing.equalTo(downloadButton.snp.leading).offset(-AppStoreSize.defaultPadding)
        }
        
        
        downloadButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.top).offset(-AppStoreSize.captionSize * 0.5)
            make.trailing.equalToSuperview()
            make.height.equalTo(AppStoreSize.captionSize + 10)
            make.width.equalTo(AppStoreSize.captionSize + 55)
        }
        
        screenShotCollectionView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.leading.equalTo(logoView.snp.leading)
            make.trailing.equalTo(downloadButton.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(item: iTuensModel) {
        titleLabel.attributedText = NSAttributedString(
            string: item.trackCensoredName ?? "",
            attributes: [
                .font: AppStoreFont.regular(ofSize: AppStoreSize.contentSize),
                .foregroundColor: UIAsset.fontBlack.color
            ]
        )
        
        subTitleLabel.attributedText = NSAttributedString(
            string: item.releaseNotes ?? "",
            attributes: [
                .font: AppStoreFont.regular(ofSize: AppStoreSize.captionSize),
                .foregroundColor: UIAsset.fontSemiBlack.color
            ]
        )
                
        logoView.load(from: item.artworkUrl512 ?? "") { _ in }
        
        // Extension 으로 뺴면 왜 안 될까 ?
        ratingView.arrangedSubviews.forEach {
            ratingView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        ratingView.smallRatingConfigure(rating: item.averageUserRating ?? 0, count: Int64(item.userRatingCount ?? 0))
        
        DispatchQueue.main.async { [weak self] in
            if let itemScreenShots = item.screenshotUrls {
                self?.screenShots = itemScreenShots.map { AppScreenShot(image: $0) }
                self?.reloadScreenShotDataSource()
            } else {
                self?.reloadScreenShotDataSource()
            }
        }
    }
}

//MARK: - CollectionView Extension
extension SearchCollectionResultCell {
    static func setupScreenShotCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
                
        let itemWidth = UIScreen.main.bounds.width * 0.3
        let itemHeight = UIScreen.main.bounds.height * 0.35
        let itemSpacing: CGFloat = AppStoreSize.defaultPadding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = itemSpacing
        layout.scrollDirection = .horizontal
        
        return layout
    }
    
    func setupScreenShotCollectionViewController() {
        screenShotCollectionView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: SearchCollectionResultCell.setupScreenShotCollectionViewFlowLayout())
        
        screenShotCollectionView.register(
            ScreenShotCell.self,
            forCellWithReuseIdentifier: ScreenShotCell.identifier
        )
    }
    
    func setupScreenShotDataSource() {
        screenShotDataSource = .init(collectionView: screenShotCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ScreenShotCell.identifier,
                for: indexPath
            ) as! ScreenShotCell
            
            cell.configure(item: item)
            return cell
        })
        
        self.screenShotCollectionView.dataSource = self.screenShotDataSource
    }
    
    func reloadScreenShotDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<ScreenshotEnum, AppScreenShot>()
        snapshot.appendSections([.main])
        snapshot.appendItems(screenShots, toSection: .main)
        screenShotDataSource.apply(snapshot,animatingDifferences: false)
    }
}
