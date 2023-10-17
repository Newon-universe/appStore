//
//  UILabelFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/19.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public struct UILabelFactory {
    public static func build(
        text: String,
        font: UIFont,
        backgroundColor: UIColor = .clear,
        textColor: UIColor = UIAsset.fontBlack.color,
        textAlignment: NSTextAlignment = .left,
        attributedText: NSAttributedString? = nil,
        maximumLines: Int = 1
    ) -> UILabel {
        let label = UILabel()
        
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor
            ]
        )
        label.textAlignment = textAlignment
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = maximumLines
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }
}
