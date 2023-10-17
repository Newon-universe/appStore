//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.framework(name: "NetworkService",
                                platform: .iOS,
                                dependencies: [
                                    .project(target: "Utils", path: "../Utils")
                          ]
)
