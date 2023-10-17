//
//  Endpoint.swift
//  NetworkService
//
//  Created by Kim Yewon on 2023/09/24.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation
import Utils

public enum Endpoint {
    
    case fetchApp(term: String, country: String = "KR", offset: Int = 0,limit: Int = 10)
    
    var request: URLRequest? {
        guard let url = self.url else { assertionFailure("URL is not valid"); return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod
        request.httpBody = self.httpBody
        request.addValues(for: self)
        request.cachePolicy = .returnCacheDataElseLoad
        
        return request
    }
    
    private var url: URL? {        
        var components = URLComponents()
        components.scheme = Constants.SCHEME
        components.host = Constants.BASE_URL
        components.path = Constants.PATH_SEARCH
        components.queryItems = self.queryItems
        
        return components.url
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .fetchApp(let term, let country, let offset, let limit):
            return [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "entity", value: "software"),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        }
    }
    
    private var httpMethod: String {
        switch self {
        case .fetchApp: return HTTP.Method.get.rawValue
        }
    }
    
    private var httpBody: Data? {
        switch self {
        case .fetchApp: return nil
        }
    }
}

//MARK: - for httpBody, Here is examples.
// return try? JSONEncoder().encode( SomeStruecture() )
// return try? JSONSerialization.data(withJSONObject: ["Key": "Value", options: []]
