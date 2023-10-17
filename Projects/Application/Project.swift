//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.app(name: "Application",
                          platform: .iOS, dependencies: [
                            .project(target: "Feature", path: "../Feature")
                          ])

