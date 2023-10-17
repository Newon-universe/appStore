//
//  UI.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim Yewon on 2023/09/18.
//

import UIKit

public struct AppStoreSize {
    public static var titleSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(32)
        } else {
            return CGFloat(36)
        }
    }
    
    public static var contentSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(19)
        } else {
            return CGFloat(23)
        }
    }
    
    public static var captionSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(14)
        } else {
            return CGFloat(18)
        }
    }
    
    public static var defaultPadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(20)
        } else {
            return CGFloat(24)
        }
    }
    
    public static var smallImageSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(60)
        } else {
            return CGFloat(75)
        }
    }
    
    public static var middleImageSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(65)
        } else {
            return CGFloat(85)
        }
    }
    
    public static var largeImageSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGFloat(100)
        } else {
            return CGFloat(120)
        }
    }
}
