//
//  String+Extensions.swift
//  Utils
//
//  Created by Kim Yewon on 2023/10/11.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation

extension String {
    public func contains(_ find: String) -> Bool{
        return self.lowercased().range(of: find) != nil
    }
    
    public func containsIgnoringCase(_ find: String) -> Bool{
        return self.lowercased().range(of: find, options: .caseInsensitive) != nil
    }
}
