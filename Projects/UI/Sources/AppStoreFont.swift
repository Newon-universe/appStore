//
//  AppStoreFont.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/19.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public struct AppStoreFont {
    // AvenirNext
    public static func regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue Regular", size: size) ?? .systemFont(ofSize: size)
    }
    
    public static func bold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue Bold", size: size) ?? .systemFont(ofSize: size)
    }
    
    public static func demibold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue Demi Bold", size: size) ?? .systemFont(ofSize: size)
    }
}
