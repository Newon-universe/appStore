//
//  SystemImageFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
public struct SystemImageFactory {
    public static func build(
        systemName: String,
        tintColor: UIColor = UIAsset.mainBlue.color
    ) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = tintColor
        
        return imageView
    }
}


