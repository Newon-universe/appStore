//
//  ScreenDetailSotCell.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import UI

class DetailScreenShotCell: UICollectionViewCell{
    static let identifier = CellIdentifier.appScreenDetailCell.rawValue
    
    private let screenView: UIImageView = {
        let view = UIImageView()
        view.addCornerRadius(radius: 15)
        view.layer.borderWidth = 0.2
        view.layer.borderColor = UIAsset.fontGray.color.cgColor
        return view
    }()
    
    private let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout(){
        screenView.backgroundColor = .systemBlue
        addSubview(screenView)
        
        screenView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
