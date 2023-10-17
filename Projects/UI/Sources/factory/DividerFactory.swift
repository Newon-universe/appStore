//
//  SpacerFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public struct DividerFactory {
    public static func build(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        color: UIColor = UIAsset.white.color
    ) -> UIView {
        let divider = UIView()
        divider.backgroundColor = color
        
        if let width = width {
            let widthConstraint = divider.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
            widthConstraint.isActive = true
            widthConstraint.priority = .defaultLow
        }
        
        if let height = height {
            let heightConstraint = divider.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            heightConstraint.isActive = true
            heightConstraint.priority = .defaultLow
        }
        
        return divider
    }
}
