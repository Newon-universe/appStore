//
//  TextFieldFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/19.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 5,
        left: 5,
        bottom: 5,
        right: 5
    )

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

public struct TextFieldFactory {
    public static func build(
        font: UIFont = AppStoreFont.regular(ofSize: AppStoreSize.contentSize),
        textColor: UIColor = UIAsset.fontBlack.color,
        backgroundColor: UIColor = UIAsset.backgroundGray.color,
        placeholder: String? = nil,
        leftView: UIView? = nil,
        rightView: UIView? = nil
    ) -> TextFieldWithPadding {
        let textField: TextFieldWithPadding = {
            let textField = TextFieldWithPadding()
            textField.font = font
            
            textField.textColor = textColor
            textField.backgroundColor = backgroundColor
            textField.placeholder = placeholder
            
            if let leftView = leftView {
                textField.leftViewMode = .always
                textField.leftView = leftView
            }
            
            if let rightView = rightView {
                textField.rightViewMode = .always
                textField.rightView = rightView
            }
            
            textField.addCornerRadius(radius: 8)
            return textField
        }()
        
        return textField
    }
}
