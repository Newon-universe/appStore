//
//  Util.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import Foundation

public struct Constants {
//    public static let BASE_URL: String = Bundle.main.infoDictionary?["BASE_URL"] as? String ?? ""
//    public static let API_KEY: String = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    public static let BASE_URL: String = "itunes.apple.com"
    public static let API_KEY: String = ""
    public static let PATH_SEARCH: String = "/search"
    public static let SCHEME = "https"
    public static let PORT: Int? = nil
}

//MARK: - This project doesn't require API KEY, and base URL is iTuens search api that
// https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html#//apple_ref/doc/uid/TP40017632-CH5-SW1
