//
//  URLRequest+Extensions.swift
//  NetworkService
//
//  Created by Kim Yewon on 2023/09/24.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation
import Utils

extension URLRequest {
    mutating func addValues(for endpoint: Endpoint) {
        switch endpoint {
        case .fetchApp:
            self.setValue(
                HTTP.Headers.Value.application.rawValue,
                forHTTPHeaderField: HTTP.Headers.Key.contentType.rawValue
            )
            
//            self.setValue(
//                Constants.API_KEY,
//                forHTTPHeaderField: HTTP.Headers.Key.apiKey.rawValue
//            )
        }
    }
}
