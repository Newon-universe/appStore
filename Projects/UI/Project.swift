//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.framework(name: "UI",
                                platform: .iOS, dependencies: [
                                    .project(target: "Utils", path: "../Utils"),
                                    .external(name: "CombineCocoa"),
                                    .external(name: "SnapKit"),
                                    .external(name: "Kingfisher")
                                ],
                                isNeedResources: true
)
