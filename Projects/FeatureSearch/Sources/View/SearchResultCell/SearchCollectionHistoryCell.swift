//
//  SearchCollectionHistoryCell.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import SnapKit
import UIKit
import Core
import UI

class SearchCollectionHistoryCell: UICollectionViewCell{
    static let identifier = CellIdentifier.searchHistoryCell.rawValue
    
    private let leftView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "magnifyingglass")
        view.tintColor = UIAsset.fontGray.color
        return view
    }()
    
    private let titleLabel = UILabelFactory.build(text: "", font: AppStoreFont.regular(ofSize: AppStoreSize.contentSize))
    private let divider = DividerFactory.build(color: UIAsset.fontSemiBlack.color)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout(){
        backgroundColor = .white
        
        [leftView, titleLabel, divider].forEach {
            addSubview($0)
        }
        
        leftView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(AppStoreSize.defaultPadding)
            make.bottom.equalToSuperview().offset(-10)
            
            make.width.equalTo(AppStoreSize.captionSize + 5)
            make.height.equalTo(leftView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-AppStoreSize.defaultPadding)
            make.top.equalTo(leftView.snp.top)
            make.bottom.equalTo(leftView.snp.bottom)
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppStoreSize.defaultPadding)
            make.left.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-AppStoreSize.defaultPadding)
            make.height.equalTo(0.2)
        }
    }
    
    func configure(item: String) {
        titleLabel.text = item
    }
}
