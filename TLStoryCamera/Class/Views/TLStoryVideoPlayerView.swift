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
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.url = url
        
        theAudioPlayer = AVPlayer.init(url: url)
        
        gpuView = GPUImageView.init(frame: self.bounds)
        self.addSubview(gpuView!)
                
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
    
    public func switchWith(filter:GPUImageCustomLookupFilter?) {
        self.gpuMovie!.removeAllTargets()

        if let f = filter {
            gpuMovie?.addTarget(f)
            f.addTarget(gpuView!)
        }else {
            gpuMovie!.addTarget(gpuView)
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
