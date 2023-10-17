//
//  API.swift
//  NetworkService
//
//  Created by Kim Yewon on 2023/09/24.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation
import Utils

enum HTTP {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum Headers {
        enum Key: String {
            case contentType = "Content-Type"
            case apiKey = "Some API Key Header name"
        }
        
        enum Value: String {
            case application = "application/json"
            var apiKey: String {
                Constants.API_KEY
            }
        }
    }
}
