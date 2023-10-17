//
//  RatingViewFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import SnapKit
import Utils

public struct RatingViewFactory {
    public static func build(
        rating: Double = 0,
        size: CGFloat = AppStoreSize.captionSize,
        count: String
    ) -> UIStackView {
        var stackView: UIStackView = {
            let view = UIStackView()
            view.axis = .horizontal
            view.spacing = 1
            view.backgroundColor = .white
            view.tintColor = UIAsset.fontGray.color
            return view
        }()
        
        stackView.configure(rating: rating, size: size, count: count)
        
        return stackView
    }
}

extension UIStackView {
    private static let starFillImage: UIImage? = {
        let image = UIImage(systemName: "star.fill")
        return image
    }()
    
    private static let starHalfImage: UIImage? = {
        let image = UIImage(systemName: "star.fill.left")
        return image
    }()

    private static let starEmptyImage: UIImage? = {
        let image = UIImage(systemName: "star")
        return image
    }()
    
    public func smallRatingConfigure(
        rating: Double = 0,
        size: CGFloat = AppStoreSize.captionSize,
        count: Int64?
    ) {
        
        for i in 0 ..< 5 {
            let button = UIButton()
            
            if i < Int(rating) {
                button.setImage(UIStackView.starFillImage, for: .normal)
            } else if Double(i) < rating {
                button.setImage(UIStackView.starHalfImage, for: .normal)
            } else {
                button.setImage(UIStackView.starEmptyImage, for: .normal)
            }
            
            button.snp.makeConstraints { make in
                make.width.equalTo(size)
                make.height.equalTo(size)
            }
            
            self.addArrangedSubview(button)
        }
        
        let label = UILabelFactory.build(
            text: " \(count.abbreviateCount)",
            font: AppStoreFont.regular(ofSize: size),
            textColor: UIAsset.fontSemiBlack.color
        )
        self.addArrangedSubview(label)
        self.tintColor = UIAsset.fontSemiBlack.color
        self.axis = .horizontal
    }
    
    public func largeRatingConfigure(
        rating: Double = 0,
        size: CGFloat = AppStoreSize.contentSize
    ){
        let label = UILabelFactory.build(
            text: " \(String(format: "%.1f", rating)) ",
            font: AppStoreFont.regular(ofSize: size),
            textColor: UIAsset.fontSemiBlack.color
        )
        
        self.addArrangedSubview(label)
        
        for i in 0 ..< 5 {
            let button = UIButton()
            
            if i < Int(rating) {
                button.setImage(UIStackView.starFillImage, for: .normal)
            } else if Double(i) < rating {
                button.setImage(UIStackView.starHalfImage, for: .normal)
            } else {
                button.setImage(UIStackView.starEmptyImage, for: .normal)
            }
            
            button.snp.makeConstraints { make in
                make.width.equalTo(size + 5)
                make.height.equalTo(size)
            }
            
            self.addArrangedSubview(button)
        }
        
        self.tintColor = UIAsset.fontSemiBlack.color
        self.axis = .horizontal
        self.spacing = 0
    }
}
