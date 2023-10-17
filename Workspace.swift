//
//  Workspace.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(name: "Application",
                          projects: ["Projects/Application",
                                     "Projects/Feature",
                                     "Projects/FeatureSearch",
                                     "Projects/FeatureSearchDemoApp",
                                     "Projects/FeatureToday",
                                     "Projects/Core",
                                     "Projects/UI",
                                     "Projects/NetworkService",
                                     "Projects/Utils"
                                    ])
