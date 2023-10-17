//
//  UIButtonFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public struct UIButtonFactory {
    public static func build(
        image: UIImage? = nil,
        title: String? = nil
    ) -> UIButton {
        let button = UIButton()
        
        if let image = image {
            button.setImage(image, for: .normal)
        }
        
        if let title = title {
            button.setTitle(title, for: .normal)
        }
        
        return button
    }
}
