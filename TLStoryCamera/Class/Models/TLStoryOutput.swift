//
//  TLStoryOutput.swift
//  TLStoryCamera
//
//  Created by garry on 2017/6/2.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import GPUImage
import SVProgressHUD
import Photos

class TLStoryOutput: NSObject {
    public      var type:TLStoryType?
    
    public      var url:URL?
    
    public      var audioEnable:Bool = true
    
    fileprivate var movieFile:GPUImageMovie?
    
    fileprivate var movieWriter:GPUImageMovieWriter?
    
    public func output(container: UIImage, callback:@escaping ((URL?, TLStoryType) -> Void)) {
        if type! == .video {
            self.outputVideo(container: container, audioEnable: audioEnable, callback: callback)
        }else {
            self.outputImage(container: container, callback: callback)
        }
    }
    
    public func saveToAlbum(container: UIImage, callback:@escaping ((Bool) -> Void)) {
        if type! == .video {
            self.outputVideoToAlbum(container: container, audioEnable: audioEnable, callback: callback)
        }else {
            self.outputImageToAlbum(container: container, callback: callback)
        }
    }
        
    fileprivate func outputImageToAlbum(container: UIImage, callback:@escaping ((Bool) -> Void)) {
        self.outputImage(container: container) { (u, type) in
            if u == nil {
                callback(false)
                return
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: u!)
            }, completionHandler: { (x, e) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "已保存到相册")
                    callback(true)
                }
            })
        }
    }
    
    fileprivate func outputVideoToAlbum(container: UIImage, audioEnable:Bool, callback:@escaping ((Bool) -> Void)) {
        self.outputVideo(container: container, audioEnable: audioEnable) { (u, type) in
            if u == nil {
                callback(false)
                return
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: u!)
            }, completionHandler: { (x, e) in
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "已保存到相册")
                    callback(true)
                }
            })
        }
    }
    
    fileprivate func outputImage(container: UIImage, callback:@escaping ((URL?, TLStoryType) -> Void)) {
        SVProgressHUD.show()
        DispatchQueue.global().async {
            guard let url = self.url, let d = try? Data.init(contentsOf: url), let image = UIImage.init(data: d) else {
                return
            }
            
            let resultImg = image.imageMontage(img: container)
            let imgData = UIImagePNGRepresentation(resultImg)
            
            let filePath = TLStoryConfiguration.photoPath?.appending("/\(Int(Date().timeIntervalSince1970))_temp.png")
            
            SVProgressHUD.dismiss()
            
            guard let p = filePath else {
                DispatchQueue.main.async {
                    callback(nil, .photo)
                }
                return
            }
            
            let resultUrl = URL.init(fileURLWithPath: p)
            
            do {
                try imgData?.write(to: resultUrl)
                DispatchQueue.main.async {
                    callback(resultUrl, .photo)
                }
            } catch {
                
            }
        }
    }
    
    fileprivate func outputVideo(container: UIImage, audioEnable:Bool, callback:@escaping ((URL?, TLStoryType) -> Void)){
        guard let url = url else {
            return
        }
        
        let asset = AVAsset.init(url: url)
        movieFile = GPUImageMovie.init(asset: asset)
        movieFile?.runBenchmark = true
        movieFile?.playAtActualSpeed = true
        
        let filePath = TLStoryConfiguration.videoPath?.appending("/\(Int(Date().timeIntervalSince1970))_temp.mp4")
        let size = self.getVideoSize(asset: asset)
        
        movieWriter = GPUImageMovieWriter.init(movieURL: URL.init(fileURLWithPath: filePath!), size: size)
        if let t = self.getVideoRotation(asset: asset) {
            movieWriter?.transform = t
        }
        
        if audioEnable {
            movieWriter?.shouldPassthroughAudio = audioEnable
            movieFile?.audioEncodingTarget = movieWriter
        }
        
        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        
        let uielement = GPUImageUIElement.init(view: UIImageView.init(image: container))
        
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
        self.movieWriter?.completionBlock = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            landBlendFilter.removeTarget(strongSelf.movieWriter)
            strongSelf.movieWriter?.finishRecording()
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                guard let p = filePath, let u = URL.init(string: p) else {
                    callback(nil, .video)
                    return
                }
                
                callback(u, .video)
            }
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
}
