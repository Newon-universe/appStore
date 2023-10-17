//
//  TextFieldContainerFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/19.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public struct TextFieldContainerFactory {
    public static func build(
        backgroundColor: UIColor = UIAsset.backgroundGray.color,
        radius: CGFloat = 8.0
    ) -> UIView {
        let textFieldContainerView: UIView = {
           let view = UIView()
            view.backgroundColor = UIAsset.clear.color
            view.addCornerRadius(radius: radius)
            return view
        }()
        
        return textFieldContainerView
    }
}
