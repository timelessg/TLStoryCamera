//
//  TLStoryOverlayOutputView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/31.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage
import MBProgressHUD

class TLStoryOverlayOutputView: UIView {
    fileprivate var videoPlayer:TLStoryVideoPlayerView?
    
    fileprivate var photoPreview:TLStoryPhotoPreviewView?
    
    fileprivate var filters:[String] = ["","lookupAbaose","lookupDianya","lookupFennen","lookupFugu","lookupHeibai","lookupHuaijiu","lookupKeke","lookupMeiyan","lookupQingliang","lookupRouguang","lookupWeimei","lookupZiran"]
    
    fileprivate var filterNames:[String] = ["无滤镜","阿宝","典雅","粉嫩","复古","黑白","怀旧","可可","美艳","晴朗","柔光","唯美","自然"]
    
    fileprivate var filterIndex:NSInteger = 0
    
    public var currentFilterNamed:String {
        get {
            return filters[filterIndex]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
            
    public func display(withVideo url:URL) {
        videoPlayer = TLStoryVideoPlayerView.init(frame: self.bounds, url: url)
        self.insertSubview(videoPlayer!, at: 0)
    }
    
    public func display(withPhoto img:UIImage) {
        photoPreview = TLStoryPhotoPreviewView.init(frame: self.bounds, image: img)
        self.insertSubview(photoPreview!, at: 0)
    }
    
    public func playerAudio(enable:Bool) {
        if let player = videoPlayer {
            player.audio(enable: enable)
        }
    }
    
    public func switchFilter(direction:UISwipeGestureRecognizerDirection) {
        if direction == .left {
            filterIndex += 1
        }
        
        if direction == .right {
            filterIndex -= 1
        }
        
        if filterIndex >= filters.count - 1 {
            filterIndex = 0
        }
        
        if filterIndex < 0 {
            filterIndex = filters.count - 1
        }
        
        JLHUD.show(text: filterNames[filterIndex], delay: 0.5)
        
        let lookupImageName = filters[filterIndex]
        let filter = lookupImageName == "" ? nil : GPUImageCustomLookupFilter.init(lookupImageNamed: lookupImageName)
        
        self.videoPlayer?.config(filter: filter)
        
        self.photoPreview?.config(filter: filter)
    }
        
    public func reset() {
        videoPlayer?.removeFromSuperview()
        photoPreview?.removeFromSuperview()
        videoPlayer = nil
        photoPreview = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
