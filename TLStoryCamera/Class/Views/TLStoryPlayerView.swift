//
//  TLStoryPlayerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage
import Photos
import SVProgressHUD

class TLStoryPlayerView: TLStoryPreviewView {
    fileprivate var isWriting: Bool = false
    
    fileprivate var player:AVPlayer? = nil
    
    fileprivate var url:URL?
    
    fileprivate var movieFile:GPUImageMovie?
    
    fileprivate var movieWriter:GPUImageMovieWriter?
    
    fileprivate lazy var audioEnableBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_voice_on"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_voice_off"), for: .selected)
        btn.addTarget(self, action: #selector(audioEnableAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate var oldVolume:Float = 0
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.url = url
        
        player = AVPlayer.init(url: url)
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.layer.insertSublayer(playerLayer, at: 0)
        player?.play()
        
        insertSubview(audioEnableBtn, at: 3)
        audioEnableBtn.sizeToFit()
        audioEnableBtn.center = CGPoint.init(x: tagsBtn.centerX - 45, y: closeBtn.centerY)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc fileprivate func playbackFinished() {
        player?.seek(to: CMTime.init(value: 0, timescale: 1))
        player?.play()
    }
    
    @objc fileprivate func audioEnableAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            oldVolume = self.player?.volume ?? 0
            self.player?.volume = 0
        }else {
            self.player?.volume = oldVolume
        }
    }
    
    internal override func saveAction() {
        self.handleVideo { [weak self] (url) -> () in
            guard let u = url else {
                return
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: u)
            }, completionHandler: { (x, e) in
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "已保存到相册")
                    self?.closeAction()
                }
            })
        }
    }
    
    internal override func publishAction() {
        self.handleVideo { [weak self] (url) -> (Void) in
            self?.closeAction()
            self?.delegate?.storyPreviewDidPublish(type: .video, url: url)
        }
    }
    
    fileprivate func getVideoSize(asset:AVAsset) -> CGSize {
        for track in asset.tracks {
            if track.mediaType == AVMediaTypeVideo {
                return track.naturalSize
            }
        }
        return TLStoryConfiguration.outputVideoSize
    }
    
    fileprivate func getVideoRotation(asset:AVAsset) -> CGAffineTransform? {
        for track in asset.tracks {
            if track.mediaType == AVMediaTypeVideo {
                return track.preferredTransform
            }
        }
        return nil
    }
    
    fileprivate func handleVideo(callback:@escaping (URL?)->(Void)) {
        guard let u = url else {
            return
        }
        
        let img = getEditImg()
        let imgView = UIImageView.init(image: img)
        
        let asset = AVAsset.init(url: u)
        movieFile = GPUImageMovie.init(asset: asset)
        movieFile?.runBenchmark = true
        movieFile?.playAtActualSpeed = true
        
        let filePath = TLStoryConfiguration.videoPath?.appending("/\(Int(Date().timeIntervalSince1970))_temp.mp4")
        let size = self.getVideoSize(asset: asset)
        
        movieWriter = GPUImageMovieWriter.init(movieURL: URL.init(fileURLWithPath: filePath!), size: size)
        if let t = self.getVideoRotation(asset: asset) {
            movieWriter?.transform = t
        }
        movieWriter?.shouldPassthroughAudio = !self.audioEnableBtn.isSelected
        movieFile?.audioEncodingTarget = movieWriter
        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        
        let uielement = GPUImageUIElement.init(view: imgView)
        
        let landBlendFilter = GPUImageAlphaBlendFilter.init()
        landBlendFilter.mix = 1
        
        let progressFilter = GPUImageFilter.init()
        
        movieFile?.addTarget(progressFilter)
        progressFilter.addTarget(landBlendFilter)
        uielement?.addTarget(landBlendFilter)
        
        landBlendFilter.addTarget(movieWriter!)
        
        progressFilter.frameProcessingCompletionBlock = { output, time in
            uielement?.update(withTimestamp: time)
        }
        
        movieWriter?.startRecording()
        movieFile?.startProcessing()
        
        SVProgressHUD.show()
        isWriting = true
        self.movieWriter?.completionBlock = { [weak self] in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else {
                return
            }
            strongSelf.isWriting = false
            landBlendFilter.removeTarget(strongSelf.movieWriter)
            strongSelf.movieWriter?.finishRecording()
            
            guard let p = filePath, let u = URL.init(string: p) else {
                callback(nil)
                return
            }
            
            callback(u)
        }
    }
    
    internal override func hideAllIcons() {
        UIView.animate(withDuration: 0.15) {
            self.audioEnableBtn.alpha = 0
            self.drawBtn.alpha = 0
            self.closeBtn.alpha = 0
            self.tagsBtn.alpha = 0
            self.textBtn.alpha = 0
            self.saveBtn.alpha = 0
            self.publishBtn.alpha = 0
        }
    }
    
    internal override func showAllIcons() {
        UIView.animate(withDuration: 0.15) {
            self.audioEnableBtn.alpha = 1
            self.drawBtn.alpha = 1
            self.closeBtn.alpha = 1
            self.tagsBtn.alpha = 1
            self.textBtn.alpha = 1
            self.saveBtn.alpha = 1
            self.publishBtn.alpha = 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
