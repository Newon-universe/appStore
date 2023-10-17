//
//  ImageCache.swift
//  UI
//
//  Created by Kim Yewon on 2023/10/09.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

internal final class ImageCache {
    
//    이번 프로젝트에서 encodedImage 를 받거나 생성하여 전송하는 경우가 없어서 사용 X
//    private lazy var encodedImageCache: NSCache<AnyObject, AnyObject> = {
//        let cache = NSCache<AnyObject, AnyObject>()
//        cache.countLimit = config.countLimit
//        return cache
//    }()
    
    internal lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    
    private let config: Config
    
    public struct Config {
        let countLimit: Int
        let memoryLimit: Int
        
        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100)
    }
    
    init(config: Config = Config.defaultConfig) {
        self.config = config
    }
}


