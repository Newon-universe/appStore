//
//  UIImageView.swift
//  UI
//
//  Created by Kim Yewon on 2023/09/28.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit
import Combine

//MARK: - Replace with ImageCache class

//extension UIImageView {
//    static var imageCache = NSMutableDictionary()
//    
//    public func load(url: String) {
//        if let data = UIImageView.imageCache.value(forKey: url),
//           let image = data as? UIImage
//        {
//            DispatchQueue.main.async { self.image = image }
//            return
//        }
//        
//        guard let url = URL(string: url) else { return }
//        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
//        
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let data = data, let image = UIImage(data: data) {
//                UIImageView.imageCache.setValue(image, forKey: url.absoluteString)
//                DispatchQueue.main.async {
//                    self?.image = image
//                }
//            }
//        }
//        task.resume()
//    }
//}

extension UIImageView {
    private static let cache = ImageCache()
    
    public func load(from url: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { self.image = nil }
        guard let url = URL(string: url) else { return }
        
        if let image = UIImageView.cache[url] {
            DispatchQueue.main.async { self.image = image }
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                UIImageView.cache.insertImage(image, for: url)
                completion(true)
                DispatchQueue.main.async {
                    self?.image = image
                }
            }else {
                completion(false)
            }
        }.resume()
    }
}
