//
//  UI+Extensions.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/19.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

extension UIView {
    public func addCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
    
    public func addRoundedCorners(corners: CACornerMask, radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = [corners]
    }
}

