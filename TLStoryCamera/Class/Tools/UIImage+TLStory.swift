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
        UIGraphicsBeginImageContext(self.size)
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        img.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
