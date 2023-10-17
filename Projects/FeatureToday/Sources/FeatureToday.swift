//
//  FeatureToday.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/19.
//

import UIKit
import UI

public class FeatureTodayViewController: UIViewController {
    
    let label = UILabelFactory.build(text: "Today Controller", font: AppStoreFont.bold(ofSize: AppStoreSize.titleSize))
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
