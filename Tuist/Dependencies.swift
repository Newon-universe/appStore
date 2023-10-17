//
//  Dependencies.swift
//  Config
//
//  Created by Kim Yewon on 2023/09/19.
//

import ProjectDescription

// in Dependencies.swift
let dependencies = Dependencies(
  swiftPackageManager: SwiftPackageManagerDependencies(
    [
        .remote(url: "https://github.com/CombineCommunity/CombineCocoa", requirement: .upToNextMajor(from: "0.4.1")),
        .remote(url: "https://github.com/SnapKit/SnapKit", requirement: .upToNextMajor(from: "5.0.0")),
        .remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .upToNextMajor(from: "7.0.0"))
    ],
    
    productTypes: [
      "CombineCocoa": .framework,
      "Snapkit": .framework
    ],
    baseSettings: .settings(
      configurations: [
        .debug(name: .debug),
        .release(name: .release),
      ]
    ),
    targetSettings: [:]
  ),
  platforms: [.iOS]
)
