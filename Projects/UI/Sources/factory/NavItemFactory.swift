//
//  NavItemFactory.swift
//  UI
//
//  Created by Kim Yewon on 2023/10/16.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

public struct NavItemFactory {
    public static func build(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        return nav
    }
}
