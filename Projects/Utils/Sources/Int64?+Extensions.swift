//
//  Int64+Extensions.swift
//  Utils
//
//  Created by Kim Yewon on 2023/10/04.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation

extension Optional where Wrapped == Int64 {
    public var abbreviateCount: String {
        if let value = self {
            switch value {
            case let x where x >= 10000:
                return "\(x / 1000)만"
            case let x where x >= 1000:
                return "\(x / 1000)천"
            default:
                return "\(value)"
            }
        } else {
            return ""
        }
    }
}
