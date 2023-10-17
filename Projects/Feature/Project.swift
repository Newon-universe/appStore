//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.framework(name: "Feature",
                                platform: .iOS, dependencies: [
                                    .project(target: "FeatureSearch", path: "../FeatureSearch"),
                                    .project(target: "FeatureToday", path: "../FeatureToday")
                                ]
)
