//
//  appStoreView.swift
//  Application
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import Feature
import FeatureToday
import FeatureSearch
import UI
import Utils
import Combine

class AppStoreViewController: UITabBarController {

    private var cancellabels = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        bind()
    }
    
    private func setupTabs() {
        let search = NavItemFactory.build(with: "검색", and: UIImage(systemName: "magnifyingglass"), vc: FeatureSearchViewController())
        let today = NavItemFactory.build(with: "투데이", and: UIImage(systemName: "doc.text.image"), vc: FeatureTodayViewController())
        
        self.setViewControllers([search, today], animated: false)
        self.tabBar.backgroundColor = .systemGray6
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: .startSearch)
            .sink { _ in
                DispatchQueue.main.async {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                    self.setViewControllers(nil, animated: true)
                    self.tabBar.backgroundColor = .clear
                }
            }
            .store(in: &cancellabels)
        
        NotificationCenter.default.publisher(for: .endSearch)
            .sink { _ in
                DispatchQueue.main.async {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.setupTabs()
                }
            }
            .store(in: &cancellabels)
    }
}
