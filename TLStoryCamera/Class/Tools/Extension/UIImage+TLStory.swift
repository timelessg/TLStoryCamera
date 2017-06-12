//
//  UIImage+TLStory.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import Foundation

extension UIImage {
    public static func imageWithStickers(named:String) -> UIImage? {
        let bundlePath = Bundle.main.path(forResource: "WBStoryStickers", ofType: "bundle")
        let bundle = Bundle.init(path: bundlePath!)
        return UIImage.init(contentsOfFile: (bundle?.path(forResource: named, ofType: "png"))!)
    }
    
    public func imageMontage(img:UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        img.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    public func rotate(by radians: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform.init(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap!.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2);
        
        bitmap!.rotate(by: radians);
        
        bitmap!.scaleBy(x: 1.0, y: -1.0);
        
        bitmap!.draw(self.cgImage!, in: CGRect.init(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage!
    }
}
