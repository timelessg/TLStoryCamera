//
//  JLHUD.swift
//  TLStoryCamera
//
//  Created by garry on 2017/9/21.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import Foundation
import MBProgressHUD

class JLHUD {
    static var hud:MBProgressHUD? = nil
    
    static func showWatting() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        self.hud = hud
    }
    
    static func hideWatting() {
        guard let h = hud else {
            return
        }
        h.hide(animated: true)
    }
    
    static func show(text:String, delay:TimeInterval) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.hide(animated: true, afterDelay: delay)
    }
}
