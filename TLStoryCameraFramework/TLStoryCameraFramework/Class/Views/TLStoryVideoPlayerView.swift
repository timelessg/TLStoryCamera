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
    
    fileprivate var filter:GPUImageCustomLookupFilter? = nil
    
    fileprivate var movieFillFilter:TLGPUImageMovieFillFiter? = TLGPUImageMovieFillFiter.init()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        didEnterBackground()
        movieFillFilter?.removeAllTargets()
        filter?.removeAllTargets()
        gpuView?.removeFromSuperview()
        filter = nil
        movieFillFilter = nil
        theAudioPlayer = nil
        gpuView = nil
        url = nil
    }
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.url = url
        
        theAudioPlayer = AVPlayer.init(url: url)
        
        gpuView = GPUImageView.init(frame: self.bounds)
        gpuView?.fillMode = .preserveAspectRatio
        self.addSubview(gpuView!)
        
        initImageMovie()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc fileprivate func didBecomeActive() {
        initImageMovie()
        config(filter: self.filter)
    }
    
    @objc fileprivate func didEnterBackground() {
        gpuMovie?.endProcessing()
        gpuMovie?.removeAllTargets()
        gpuMovie = nil
    }
    
    fileprivate func initImageMovie() {
        if gpuMovie != nil {
            return
        }
        
        gpuMovie = TLGPUImageMovie.init(url: url!)
        gpuMovie!.shouldRepeat = true
        gpuMovie!.playAtActualSpeed = true
        gpuMovie!.startProcessingCallback = { [weak self] in
            if let strongSelf = self {
                strongSelf.theAudioPlayer!.seek(to: kCMTimeZero)
                strongSelf.theAudioPlayer!.play()
            }
        }
        
        gpuMovie?.addTarget(movieFillFilter)
        movieFillFilter?.addTarget(gpuView)
        gpuMovie!.startProcessing()
    }
    
    public func config(filter:GPUImageCustomLookupFilter?) {
        self.gpuMovie?.removeAllTargets()

        self.filter = filter
        if let f = filter {
            gpuMovie?.addTarget(f)
            f.addTarget(gpuView!)
        }else {
            gpuMovie?.addTarget(gpuView)
        }
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
