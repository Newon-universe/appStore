//
//  FooterIndicatorView.swift
//  UI
//
//  Created by Kim Yewon on 2023/10/07.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import SnapKit

public class FooterIndicatorView: UICollectionReusableView {
    public static let identifier = "FooterIndicatorView"
    
    private let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    public func toggleLoading(isEnabled: Bool) {
        if isEnabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
