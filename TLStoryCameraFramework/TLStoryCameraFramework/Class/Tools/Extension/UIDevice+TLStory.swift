//
//  UIDevice+TLStory.swift
//  TLStoryCameraFramework
//
//  Created by garry on 2018/2/7.
//  Copyright © 2018年 com.garry. All rights reserved.
//

import Foundation

extension UIDevice {
    static public var isX:Bool {
        get {
            return UIScreen.main.bounds.height == 812
        }
    }
    
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

