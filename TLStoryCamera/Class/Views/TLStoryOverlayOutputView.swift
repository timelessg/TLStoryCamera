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
    
    fileprivate var photoPreview:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    public func display(withVideo url:URL) {
        videoPlayer = TLStoryVideoPlayerView.init(frame: self.bounds, url: url)
        self.insertSubview(videoPlayer!, at: 0)
    }
    
    public func display(withPhoto img:UIImage) {
        photoPreview = UIImageView.init(frame: self.bounds)
        photoPreview?.contentMode = .scaleAspectFill
        photoPreview?.image = img
        self.insertSubview(photoPreview!, at: 0)
    }
    
    public func playerAudio(enable:Bool) {
        if let player = videoPlayer {
            player.audio(enable: enable)
        }
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
