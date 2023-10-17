//
//  FeatureSearchDemoAppSceneDelegate.swift
//  FeatureSearchDemoApp
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import FeatureSearch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let vc = FeatureSearchViewController()
        let navigation = UINavigationController(rootViewController: vc)
        
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
    }

}
