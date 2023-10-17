//
//  FeatureSearchDetailViewModel.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/10/05.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation
import Combine
import Core
import NetworkService
import Utils

public final class FeatureSearchDetailViewModel: ObservableObject {
    
    private var cancellabels = Set<AnyCancellable>()
    @Published public var item: iTuensModel
    
    var screenShots: [AppScreenShot] {
        item.screenshotUrls?.compactMap { AppScreenShot(image: $0) } ?? []
    }
    
    init(item: iTuensModel) {
        self.item = item
    }
}
