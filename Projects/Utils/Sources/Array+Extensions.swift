//
//  Array+Extensions.swift
//  Utils
//
//  Created by Kim Yewon on 2023/09/20.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation

extension Array {

  public var tail: Array {
    return Array(self.dropFirst())
  }

}
