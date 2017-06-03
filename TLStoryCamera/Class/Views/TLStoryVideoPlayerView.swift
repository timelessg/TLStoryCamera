//
//  TLStoryVideoPlayerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/31.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class TLStoryVideoPlayerView: UIView {
    public var url:URL?
    
    public var audioEnable:Bool = true

    fileprivate var player:AVPlayer? = nil
    
    fileprivate var oldVolume:Float = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.url = url
        
        player = AVPlayer.init(url: url)
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.layer.insertSublayer(playerLayer, at: 0)
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    public func audio(enable:Bool) {
        if enable {
            self.player?.volume = oldVolume
        }else {
            oldVolume = self.player?.volume ?? 0
            self.player?.volume = 0
        }
        audioEnable = enable
    }
    
    @objc fileprivate func playbackFinished() {
        player?.seek(to: CMTime.init(value: 0, timescale: 1))
        player?.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
