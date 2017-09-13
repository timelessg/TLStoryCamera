//
//  TLStoryCapturePreviewView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage

class TLStoryCapturePreviewView: GPUImageView {    
    fileprivate var videoCamera:GPUImageStillCamera?
    
    fileprivate var filterView:GPUImageView?
    
    fileprivate var beautifyFilter = TLStoryConfiguration.openBeauty ? GPUImageBeautifyFilter.init() : GPUImageFilter.init()
    
    fileprivate var movieWriter:GPUImageMovieWriter?
    
    fileprivate var currentVideoPath:URL?
    
    fileprivate var currentPhotoPath:URL?
    
    fileprivate var focusRing:UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 25
        view.isHidden = true
        return view
    }()
    
    fileprivate var animEnd:Bool = true
    
    fileprivate var focusAnim:CAAnimationGroup = {
        let zoomAnim = CABasicAnimation.init(keyPath: "transform.scale")
        zoomAnim.fromValue = 1.8
        zoomAnim.byValue = 0.8
        zoomAnim.toValue = 1
        zoomAnim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        
        let alphaAnim = CABasicAnimation.init(keyPath: "opacity")
        alphaAnim.fromValue = 1
        alphaAnim.toValue = 0
        
        let group = CAAnimationGroup.init()
        group.animations = [zoomAnim,alphaAnim]
        group.duration = 0.3
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        return group
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(focusRing)
        focusAnim.delegate = self        
    }
    
    public func cameraSwitch(open:Bool) {
        open ? videoCamera?.startCapture() : videoCamera?.stopCapture()
    }
    
    public func camera(distance:CGFloat) {
        let maxZoomFactor = videoCamera?.inputCamera.activeFormat.videoMaxZoomFactor ?? 1
        let max = maxZoomFactor > TLStoryConfiguration.maxVideoZoomFactor ? TLStoryConfiguration.maxVideoZoomFactor : maxZoomFactor
        let per = MaxDragOffset / max
        let zoom = distance / per
        self.setVideoZoomFactor(zoom: zoom)
    }
    
    fileprivate func setVideoZoomFactor(zoom:CGFloat) {
        do {
            try videoCamera?.inputCamera.lockForConfiguration()
            videoCamera?.inputCamera.videoZoomFactor = zoom + 1.0
            videoCamera?.inputCamera.unlockForConfiguration()
        } catch {
            
        }
    }
    
    public func startCapture() {
        videoCamera?.startCapture()
    }
    
    public func stopCapture() {
        videoCamera?.stopCapture()
    }
    
    public func startRecording() {
        DispatchQueue.main.async {
            self.movieWriter?.startRecording()
        }
    }
    
    public func initCamera() {
        videoCamera = GPUImageStillCamera.init(sessionPreset: TLStoryConfiguration.captureSessionPreset, cameraPosition: .back)
        videoCamera!.outputImageOrientation = .portrait
        videoCamera!.horizontallyMirrorFrontFacingCamera = true
        videoCamera!.removeAllTargets()
        videoCamera!.addTarget(beautifyFilter as! GPUImageInput)
        beautifyFilter.addTarget(self)
    }
    
    public func configVideoRecording() {
        currentVideoPath = TLStoryOutput.outputFilePath(type: .video)
        let size = CGSize.init(width: TLStoryConfiguration.videoSetting["AVVideoWidthKey"] as! Int, height: TLStoryConfiguration.videoSetting["AVVideoHeightKey"] as! Int)
        self.movieWriter = GPUImageMovieWriter.init(movieURL: self.currentVideoPath, size: size, fileType: TLStoryConfiguration.videoFileType, outputSettings: TLStoryConfiguration.videoSetting)
        self.beautifyFilter.addTarget(self.movieWriter!)
        self.movieWriter?.encodingLiveVideo = true
    }
    
    public func configAudioRecording() {
        movieWriter?.setHasAudioTrack(true, audioSettings: TLStoryConfiguration.audioSetting)
        videoCamera?.audioEncodingTarget = movieWriter
    }
    
    public func rotateCamera() {
        videoCamera?.rotateCamera()
    }
    
    public func pauseCamera() {
        self.videoCamera?.pauseCapture()
    }
    
    public func resumeCamera() {
        if let vPath = currentVideoPath {
            do {
                try FileManager.default.removeItem(at: vPath)
                currentVideoPath = nil
            } catch {
                print("video delete failure")
            }
        }
        if let pPath = currentPhotoPath {
            do {
                try FileManager.default.removeItem(at: pPath)
                currentPhotoPath = nil
            } catch {
                print("photo delete failure")
            }
        }
        
        videoCamera?.resumeCameraCapture()
        self.setVideoZoomFactor(zoom: 0)
    }
    
    public func finishRecording(complete:@escaping ((URL?) -> Void)) {
        movieWriter?.finishRecording(completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.beautifyFilter.removeTarget(self?.movieWriter!)
                self?.movieWriter = nil
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let path = strongSelf.currentVideoPath else {
                    complete(nil)
                    return
                }
                
                complete(path)
            }
        })
    }
    
    public func capturePhoto(complete:@escaping ((UIImage?) -> Void)){
        videoCamera?.capturePhotoAsImageProcessedUp(toFilter: beautifyFilter as! GPUImageOutput & GPUImageInput, with: .up, withCompletionHandler: { [weak self] (image, error) in
            DispatchQueue.main.async {
                self?.beautifyFilter.removeTarget(self?.movieWriter!)
                self?.movieWriter = nil
                complete(image)
            }
        })
    }
    
    public func flashStatusChange() -> AVCaptureDevice.TorchMode {
        if !videoCamera!.inputCamera.hasFlash || !videoCamera!.inputCamera.hasTorch {
            return .auto
        }
        
        let rawValue = videoCamera!.inputCamera.torchMode.rawValue + 1
        let mode = AVCaptureDevice.TorchMode(rawValue: rawValue + 1 > 3 ? 0 : rawValue)!
        do {
            try videoCamera?.inputCamera.lockForConfiguration()
            videoCamera?.inputCamera.torchMode = mode
            videoCamera?.inputCamera.unlockForConfiguration()
        } catch {
            
        }
        return mode
    }
    
    public func focus(point:CGPoint) {
        if !videoCamera!.inputCamera.isFocusModeSupported(.autoFocus) || !videoCamera!.inputCamera.isFocusPointOfInterestSupported {
            return
        }
        
        do {
            try videoCamera?.inputCamera.lockForConfiguration()
            videoCamera!.inputCamera.focusMode = .autoFocus
            videoCamera!.inputCamera.focusPointOfInterest = point
            videoCamera!.inputCamera.unlockForConfiguration()
        } catch {
            
        }
        
        self.showFocusRing(point: point)
    }
        
    fileprivate func showFocusRing(point:CGPoint) {
        if !animEnd {
            return
        }
        focusRing.isHidden = false
        focusRing.center = point
        animEnd = false
        focusRing.layer.add(focusAnim, forKey: nil)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryCapturePreviewView: CAAnimationDelegate {
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {
            return
        }
        focusRing.layer.removeAllAnimations()
        focusRing.isHidden = true
        focusRing.alpha = 0
        animEnd = true
    }
}
