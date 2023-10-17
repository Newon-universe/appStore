//
//  ScreenShotCell.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import SnapKit
import UIKit
import UI
import Combine
import CombineCocoa


class ScreenShotCell: UICollectionViewCell {
    private var cancellabels = Set<AnyCancellable>()
    static let identifier = CellIdentifier.appScreenShotCell.rawValue
    
    private let screenView: UIImageView = {
        let view = UIImageView()
        view.addCornerRadius(radius: 15)
        view.layer.borderWidth = 0.2
        view.layer.borderColor = UIAsset.fontGray.color.cgColor
        return view
    }()
    
    private let activityIndicator = UIActivityIndicatorView()

    private let spacer: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.startAnimating()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout(){
        screenView.backgroundColor = UIAsset.backgroundGray.color
        [screenView, spacer, activityIndicator].forEach { addSubview($0) }
        
        screenView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppStoreSize.defaultPadding)
            make.bottom.equalToSuperview().offset(-AppStoreSize.defaultPadding)
            make.leading.trailing.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(screenView.snp.center)
            make.width.equalTo(AppStoreSize.titleSize)
            make.height.equalTo(AppStoreSize.titleSize)
        }
        
        spacer.snp.makeConstraints { make in
            make.top.equalTo(screenView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(AppStoreSize.defaultPadding)
        }
    }
    
    func configure(item: AppScreenShot) {
        screenView.load(from: item.image) { successCall in
            DispatchQueue.main.async {
                if successCall == true { self.activityIndicator.stopAnimating() }
                else { self.activityIndicator.startAnimating() }
            }
        }
    }
}
