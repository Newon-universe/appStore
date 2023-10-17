//
//  ImageCache+Extension.swift
//  UI
//
//  Created by Kim Yewon on 2023/10/09.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

extension ImageCache: ImageCacheType {
    func image(for url: URL) -> UIImage? {
        if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
            return decodedImage
        }
        
        return nil
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        decodedImageCache.setObject(image, forKey: url as AnyObject)
    }
    
    func removeImage(for url: URL) {
        decodedImageCache.removeObject(forKey: url as AnyObject)
    }
    
    func removeAllImages() {
        decodedImageCache.removeAllObjects()
    }
    
    subscript(url: URL) -> UIImage? {
        get {
            return image(for: url)
        }
        set {
            return insertImage(newValue, for: url)
        }
    }
}
