//
//  TLStoryOutput.swift
//  TLStoryCamera
//
//  Created by garry on 2017/6/2.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import GPUImage
import MBProgressHUD
import Photos

class TLStoryOutput: NSObject {
    public      var type:TLStoryType?
    
    public      var url:URL?
    
    public      var image:UIImage?
    
    public      var audioEnable:Bool = true
    
    fileprivate var movieFile:GPUImageMovie?
    
    fileprivate var movieWriter:GPUImageMovieWriter?
    
    public func output(filterNamed:String, container: UIImage, callback:@escaping ((URL?, TLStoryType) -> Void)) {
        if type! == .video {
            self.outputVideo(filterNamed: filterNamed, container: container, audioEnable: audioEnable, callback: callback)
        }else {
            self.outputImage(filterNamed: filterNamed, container: container, callback: callback)
        }
    }
    
    public func saveToAlbum(filterNamed:String, container: UIImage, callback:@escaping ((Bool) -> Void)) {
        if type! == .video {
            self.outputVideoToAlbum(filterNamed: filterNamed, container: container, audioEnable: audioEnable, callback: callback)
        }else {
            self.outputImageToAlbum(filterNamed: filterNamed, container: container, callback: callback)
        }
    }
    
    fileprivate func outputImageToAlbum(filterNamed:String, container: UIImage, callback:@escaping ((Bool) -> Void)) {
        self.outputImage(filterNamed: filterNamed, container: container) { (u, type) in
            if u == nil {
                callback(false)
                return
            }
            JLHUD.showWatting()
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: u!)
            }, completionHandler: { (x, e) in
                DispatchQueue.main.async {
                    JLHUD.hideWatting()
                    JLHUD.show(text: "已保存到相册", delay:1)
                    callback(true)
                }
            })
        }
    }
    
    fileprivate func outputVideoToAlbum(filterNamed:String, container: UIImage, audioEnable:Bool, callback:@escaping ((Bool) -> Void)) {
        self.outputVideo(filterNamed: filterNamed, container: container, audioEnable: audioEnable) { (u, type) in
            if u == nil {
                callback(false)
                return
            }
            JLHUD.showWatting()
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: u!)
            }, completionHandler: { (x, e) in
                DispatchQueue.main.async {
                    JLHUD.hideWatting()
                    JLHUD.show(text: "已保存到相册", delay:1)
                    callback(true)
                }
            })
        }
    }
    
    fileprivate func outputImage(filterNamed:String, container: UIImage, callback:@escaping ((URL?, TLStoryType) -> Void)) {
        JLHUD.showWatting()
        var cImg:UIImage? = nil
        if filterNamed != "" {
            let picture = GPUImagePicture.init(image: self.image!)
            
            let filter = GPUImageCustomLookupFilter.init(lookupImageNamed: filterNamed)
            
            picture?.addTarget(filter)
            picture?.processImage()
            
            filter.useNextFrameForImageCapture()
            
            guard let img = filter.imageFromCurrentFramebuffer() else {
                JLHUD.hideWatting()
                callback(nil, .photo)
                return
            }
            picture?.removeAllTargets()
            cImg = img
        }else {
            cImg = self.image
        }
        
        let resultImg = cImg!.imageMontage(img: container)
        let imgData = UIImageJPEGRepresentation(resultImg, 1)
        
        let filePath = TLStoryOutput.outputFilePath(type: .photo)
        
        do {
            try imgData?.write(to: filePath)
            JLHUD.hideWatting()
            callback(filePath, .photo)
        } catch {
            
        }
    }
    
    fileprivate func outputVideo(filterNamed:String, container: UIImage, audioEnable:Bool, callback:@escaping ((URL?, TLStoryType) -> Void)){
        guard let url = url else {
            return
        }
        
        let asset = AVAsset.init(url: url)
        movieFile = GPUImageMovie.init(asset: asset)
        movieFile?.runBenchmark = true
        
        let filePath = TLStoryConfiguration.videoPath?.appending("/\(Int(Date().timeIntervalSince1970))_temp.mp4")
        let size = self.getVideoSize(asset: asset)
        
        var img:UIImage? = nil
        
        movieWriter = GPUImageMovieWriter.init(movieURL: URL.init(fileURLWithPath: filePath!), size: size)
        if let t = self.getVideoRotation(asset: asset) {
            movieWriter?.transform = t
            img = container.rotate(by: -CGFloat(acosf(Float(t.a))))
        }
        
        if audioEnable {
            movieWriter?.shouldPassthroughAudio = audioEnable
            movieFile?.audioEncodingTarget = movieWriter
        }
        
        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        
        let imgview = UIImageView.init(image: img!)
        
        let uielement = GPUImageUIElement.init(view: imgview)
        
        let landBlendFilter = TLGPUImageAlphaBlendFilter.init()
        landBlendFilter.mix = 1
        
        let progressFilter = filterNamed == "" ? GPUImageFilter.init() : GPUImageCustomLookupFilter.init(lookupImageNamed: filterNamed)
        
        movieFile?.addTarget(progressFilter as! GPUImageInput)
        progressFilter.addTarget(landBlendFilter)
        uielement?.addTarget(landBlendFilter)
        
        landBlendFilter.addTarget(movieWriter!)
        
        progressFilter.frameProcessingCompletionBlock = { output, time in
            uielement?.update(withTimestamp: time)
        }
        
        movieWriter?.startRecording()
        movieFile?.startProcessing()
        
        JLHUD.showWatting()
        self.movieWriter?.completionBlock = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            landBlendFilter.removeAllTargets()
            progressFilter.removeAllTargets()
            strongSelf.movieFile?.removeAllTargets()
            strongSelf.movieWriter?.finishRecording()
            
            DispatchQueue.main.async {
                JLHUD.hideWatting()
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
    
    public static func outputFilePath(type:TLStoryType) -> URL {
        let path = type == .video ? TLStoryConfiguration.videoPath : TLStoryConfiguration.photoPath
        let filePath = path?.appending("/\(Int(Date().timeIntervalSince1970)).\(type == .video ? "mp4" : "png")")
        do {
            try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        return URL.init(fileURLWithPath: filePath!)
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

