//
//  TLStoryVideoPlayerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/31.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage

class TLStoryVideoPlayerView: UIView {
    public var url:URL?
    
    public var gpuMovie:TLGPUImageMovie? = nil
    
    public var audioEnable:Bool = true
    
    fileprivate var gpuView:GPUImageView? = nil
    
    fileprivate var theAudioPlayer:AVPlayer? = nil
    
    fileprivate var oldVolume:Float = 0
    
    fileprivate var filters:[String] = ["lookupAbaose","lookupDianya","lookupFennen","lookupFugu","lookupHeibai","lookupHuaijiu","lookupKeke","lookupMeiyan","lookupQingliang","lookupRouguang","lookupTianmei","lookupWeimei","lookupZiran"]
    
    fileprivate var filterIndex:NSInteger = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.url = url
        
        theAudioPlayer = AVPlayer.init(url: url)
        
        gpuView = GPUImageView.init(frame: self.bounds)
        self.addSubview(gpuView!)
        
        createMovie()
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    public func switchFilter(direction:UISwipeGestureRecognizerDirection) {
        if direction == .left {
            filterIndex += 1
        }
        
        if direction == .right {
            filterIndex -= 1
        }
        
        if filterIndex >= filters.count - 1 || filterIndex <= 0 {
            filterIndex = 0
        }
        
        self.gpuMovie!.removeAllTargets()
        
        let lookupImageName = filters[filterIndex]
        let filter = GPUImageCustomLookupFilter.init(lookupImageNamed: lookupImageName)
        
        gpuMovie!.addTarget(filter)
        filter.addTarget(gpuView!)
    }
    
    func createMovie() {
        gpuMovie = TLGPUImageMovie.init(url: url)
        gpuMovie!.shouldRepeat = true
        gpuMovie!.startProcessingCallback = { [weak self] in
            if let strongSelf = self {
                strongSelf.theAudioPlayer!.seek(to: kCMTimeZero)
                strongSelf.theAudioPlayer!.play()
            }
        }
        
        gpuMovie!.addTarget(gpuView)
        gpuMovie!.startProcessing()
    }
    
    @objc fileprivate func didBecomeActive() {
        createMovie()
    }
    
    @objc fileprivate func didEnterBackground() {
        gpuMovie!.endProcessing()
        gpuMovie!.removeAllTargets()
        gpuMovie = nil
    }
    
    public func audio(enable:Bool) {
        if enable {
            theAudioPlayer!.volume = oldVolume
        }else {
            oldVolume = theAudioPlayer!.volume
            theAudioPlayer!.volume = 0
        }
        audioEnable = enable
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
