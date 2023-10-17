//
//  DataSourceItem.swift
//  FeatureSearch
//
//  Created by Kim Yewon on 2023/09/28.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation

public enum DataSourceItem: Hashable {
    case searchResult(iTuensModel)
    case searchHistory(History)
}
