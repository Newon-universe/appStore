//
//  UIStackView+Extensions.swift
//  UI
//
//  Created by Kim Yewon on 2023/10/04.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

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
    
    public func configure(
        rating: Double = 0,
        size: CGFloat = AppStoreSize.captionSize,
        count: String
    ) {
        DispatchQueue.main.async {
            self.arrangedSubviews.forEach {
                self.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            
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
                    make.width.equalTo(AppStoreSize.captionSize)
                    make.height.equalTo(AppStoreSize.captionSize)
                }
                
                self.addArrangedSubview(button)
            }
            
            let label = UILabelFactory.build(
                text: " \(count)",
                font: AppStoreFont.regular(ofSize: AppStoreSize.captionSize),
                textColor: UIAsset.fontGray.color
            )
            
            self.addArrangedSubview(label)
        }
    }
}
