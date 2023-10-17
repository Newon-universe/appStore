//
//  NotificactionCenter.Name+Extension.swift
//  Utils
//
//  Created by Kim Yewon on 2023/10/16.
//  Copyright © 2023 labo.summer. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let searchAppPagingTriggered = Notification.Name("searchAppPagingTriggered")
    public static let startSearch = Notification.Name("startSearch")
    public static let enterSearch = Notification.Name("enterSearch")
    public static let endSearch = Notification.Name("endSearch")
}
