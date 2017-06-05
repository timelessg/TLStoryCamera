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
    public var type:TLStoryType?
    
    fileprivate var url:URL?

    fileprivate var videoPlayer:TLStoryVideoPlayerView?
    
    fileprivate var photoPreview:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    public func display(with url:URL, type:TLStoryType) {
        if type == .photo {
            photoPreview = UIImageView.init()
            self.insertSubview(photoPreview!, at: 0)
            if let d = try? Data.init(contentsOf: url) {
                photoPreview?.image = UIImage.init(data: d)
            }
        }else {
            videoPlayer = TLStoryVideoPlayerView.init(frame: self.bounds, url: url)
            self.insertSubview(videoPlayer!, at: 0)
        }
        self.type = type
        self.url = url
    }
    
    public func playerAudio(enable:Bool) {
        if let player = videoPlayer, type! == .video {
            player.audio(enable: enable)
        }
    }
    
    public func getUrl() -> (URL?, TLStoryType?) {
        return (url, type)
    }
    
    public func getAudioEnable() -> Bool {
        return self.videoPlayer!.audioEnable
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
