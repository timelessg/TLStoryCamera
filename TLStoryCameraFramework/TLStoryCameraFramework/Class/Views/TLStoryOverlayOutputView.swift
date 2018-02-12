//
//  TLStoryOverlayOutputView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/31.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage

class TLStoryOverlayOutputView: UIView {
    fileprivate var videoPlayer:TLStoryVideoPlayerView?
    
    fileprivate var photoPreview:TLStoryPhotoPreviewView?
    
    fileprivate var filters:[[String:String]] = {
        var array = [[String:String]]()
                
        let bundlePath = Bundle.main.path(forResource: "TLStoryCameraResources", ofType: "bundle")
        let bundle = Bundle.init(path: bundlePath!)
        
        if let path = bundle?.path(forResource: "TLStoryCameraFilter", ofType: "plist"), let filters = NSArray.init(contentsOfFile: path) as? [[String:String]] {
            var i = 1
            for filterDic in filters {
                if let name = filterDic["name"], let filter = filterDic["filterimg"] {
                    let dic = ["name":name,"filterNamed":filter]
                    array.append(dic)
                }
            }
        }
        return array
    }()
    
    fileprivate var filterIndex:NSInteger = 0
    
    public var currentFilterNamed:String {
        get {
            return filters[filterIndex]["filterNamed"]!
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
        
        JLHUD.show(text: filters[filterIndex]["name"]!, delay: 0.5)
        
        let lookupImageName = filters[filterIndex]["filterNamed"]!
        let filter = lookupImageName == "" ? nil : GPUImageCustomLookupFilter.init(lookupImageNamed: lookupImageName)
        
        self.videoPlayer?.config(filter: filter)
        
        self.photoPreview?.config(filter: filter)
    }
        
    public func reset() {
        videoPlayer?.removeFromSuperview()
        photoPreview?.removeFromSuperview()
        videoPlayer = nil
        photoPreview = nil
        filterIndex = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
