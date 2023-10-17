//
//  ImageCacheType.swift
//  UI
//
//  Created by Kim Yewon on 2023/10/09.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import UIKit

protocol ImageCacheType {
    func image(for url: URL) -> UIImage?
    
    func insertImage(_ image: UIImage?, for url: URL)
    
    func removeImage(for url: URL)
    
    func removeAllImages()
    
    subscript(_ url: URL) -> UIImage? { get set }
}
