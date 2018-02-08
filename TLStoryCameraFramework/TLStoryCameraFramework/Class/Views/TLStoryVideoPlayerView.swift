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
    
    fileprivate var asset:AVAsset? = nil;
    
    fileprivate var gpuView:GPUImageView? = nil
    
    fileprivate var theAudioPlayer:AVPlayer? = nil
    
    fileprivate var oldVolume:Float = 0
    
    fileprivate var filter:GPUImageCustomLookupFilter? = nil
    
    deinit {
        didEnterBackground()
        NotificationCenter.default.removeObserver(self)
    }
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.url = url
        
        self.asset = AVAsset.init(url: url)
        
        theAudioPlayer = AVPlayer.init(url: url)
        
        gpuView = GPUImageView.init(frame: self.bounds)
        gpuView?.fillMode = .preserveAspectRatio
        self.addSubview(gpuView!)
        
        repairVideoDirection()
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
        
        gpuMovie!.addTarget(gpuView)
        gpuMovie!.startProcessing()
    }
    
    public func config(filter:GPUImageCustomLookupFilter?) {
        gpuMovie?.removeAllTargets()
        
        self.filter = filter
        if let f = filter {
            gpuMovie?.addTarget(f)
            f.addTarget(gpuView!)
        }else {
            gpuMovie?.addTarget(gpuView)
        }
        repairVideoDirection()
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
    
    fileprivate func repairVideoDirection() {
        let tracks = self.asset!.tracks(withMediaType: AVMediaType.video)
        
        if tracks.count > 0 {
            let track = tracks.first
            let t = track!.preferredTransform
            
            if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
                gpuView?.setInputRotation(GPUImageRotationMode.rotateRight, at: 0)
            }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
                gpuView?.setInputRotation(GPUImageRotationMode.rotateLeft, at: 0)
            }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
                gpuView?.setInputRotation(GPUImageRotationMode.flipVertical, at: 0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
