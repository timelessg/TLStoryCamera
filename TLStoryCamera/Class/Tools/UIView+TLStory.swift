//
//  UIView+TLStory.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

extension UIView {
    public var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var r = self.frame
            r.origin.x = newValue
            self.frame = r
        }
    }
    
    public var y: CGFloat {
        get{
            return self.frame.origin.y
        }
        set {
            var r = self.frame
            r.origin.y = newValue
            self.frame = r
        }
    }
    
    public var rightX: CGFloat {
        get {
            return self.x + self.width
        }
        set {
            var r = self.frame
            r.origin.x = newValue - frame.size.width
            self.frame = r
        }
    }
    
    public var bottomY: CGFloat {
        get {
            return self.y + self.height
        }
        set {
            var r = self.frame
            r.origin.y = newValue - frame.size.height
            self.frame = r
        }
    }
    
    public var centerX : CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    public var centerY : CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var r = self.frame
            r.size.width = newValue
            self.frame = r
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var r = self.frame
            r.size.height = newValue
            self.frame = r
        }
    }
    
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    
    public var currentController:UIViewController? {
        get {
            var responder = self.next;
            while (responder != nil) {
                if (responder!.isKind(of: UIViewController.self)) {
                    return responder as? UIViewController;
                }
                responder = responder?.next;
            }
            return nil;
        }
    }
    
    public func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
