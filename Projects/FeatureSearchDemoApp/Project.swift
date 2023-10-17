//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/19.
//

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.app(name: "FeatureSearchDemoApp",
                          platform: .iOS, dependencies: [
                            .project(target: "FeatureSearch", path: "../FeatureSearch")
                          ])
