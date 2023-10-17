//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/19.
//

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.framework(name: "FeatureToday",
                                platform: .iOS, dependencies: [
                                    .project(target: "Core", path: "../Core"),
                                    .project(target: "UI", path: "../UI")
                                ],
                                isNeedResources: true
)
