//
//  TLStoryOutput.swift
//  TLStoryCamera
//
//  Created by garry on 2017/6/2.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import GPUImage
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
        DispatchQueue.global().async {
            var cImg:UIImage? = nil
            
            if filterNamed != "" {
                let picture = GPUImagePicture.init(image: self.image!)
                
                let filter = GPUImageCustomLookupFilter.init(lookupImageNamed: filterNamed)
                
                picture?.addTarget(filter)
                picture?.processImage()
                
                filter.useNextFrameForImageCapture()
                
                guard let img = filter.imageFromCurrentFramebuffer() else {
                    DispatchQueue.main.async(execute: {
                        JLHUD.hideWatting()
                        callback(nil, .photo)
                    })
                    return
                }
                picture?.removeAllTargets()
                cImg = img
            }else {
                cImg = self.image
            }
            
            let resultImg = cImg!.imageMontage(img: container,bgColor: UIColor.black,size: TLStoryConfiguration.outputPhotoSize)
            let imgData = UIImageJPEGRepresentation(resultImg, 1)
            
            guard let exportUrl = TLStoryOutput.outputFilePath(type: .photo, isTemp: false) else {
                DispatchQueue.main.async(execute: {
                    JLHUD.hideWatting()
                    callback(nil, .photo)
                })
                return
            }
            
            DispatchQueue.main.async(execute: {
                JLHUD.hideWatting()
                do {
                    try imgData?.write(to: exportUrl)
                    callback(exportUrl, .photo)
                } catch {
                    callback(nil, .photo)
                }
            })
        }
    }
    
    fileprivate func outputVideo(filterNamed:String, container: UIImage, audioEnable:Bool, callback:@escaping ((URL?, TLStoryType) -> Void)){
        guard let url = url else {
            return
        }
        
        let asset = AVAsset.init(url: url)
        movieFile = GPUImageMovie.init(asset: asset)
        movieFile?.runBenchmark = false
        
        let movieFillFilter = TLGPUImageMovieFillFiter.init()
        movieFillFilter.fillMode = .preserveAspectRatio
        movieFile?.addTarget(movieFillFilter)
        
        guard let exportUrl = TLStoryOutput.outputFilePath(type: .video, isTemp: false) else {
            callback(nil, .video)
            return
        }
        
        movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl, size: TLStoryConfiguration.outputVideoSize)
        
        let tracks = asset.tracks(withMediaType: AVMediaType.video)
        
        let t = tracks.first!.preferredTransform
        
        let img = container.rotate(by: -CGFloat(acosf(Float(t.a))))
        
        if audioEnable {
            movieWriter?.shouldPassthroughAudio = audioEnable
            movieFile?.audioEncodingTarget = movieWriter
        }
        
        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        
        let imgview = UIImageView.init(image: img)
        
        let uielement = GPUImageUIElement.init(view: imgview)
        
        let landBlendFilter = TLGPUImageAlphaBlendFilter.init()
        landBlendFilter.mix = 1
        
        let progressFilter = filterNamed == "" ? GPUImageFilter.init() : GPUImageCustomLookupFilter.init(lookupImageNamed: filterNamed)
        
        movieFillFilter.addTarget(progressFilter as! GPUImageInput)
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
            
            movieFillFilter.removeAllTargets()
            landBlendFilter.removeAllTargets()
            progressFilter.removeAllTargets()
            uielement?.removeAllTargets()
            
            strongSelf.movieFile?.removeAllTargets()
            strongSelf.movieWriter?.finishRecording()
            strongSelf.movieFile?.audioEncodingTarget = nil
            
            DispatchQueue.main.async {
                JLHUD.hideWatting()
                callback(exportUrl, .video)
            }
        }
        
        self.movieWriter?.failureBlock = { x in
            JLHUD.hideWatting()
            JLHUD.show(text: "Failure", delay: 0.2)
        }
    }
    
    public static func outputFilePath(type:TLStoryType, isTemp:Bool) -> URL? {
        do {
            try? FileManager.default.createDirectory(atPath: type == .video ? TLStoryConfiguration.videoPath! : TLStoryConfiguration.photoPath!, withIntermediateDirectories: true, attributes: nil)
            
            if type == .video {
                let fileName = isTemp ? "mov_tmp.mp4" : "mov_out.mp4"
                let url = URL.init(fileURLWithPath: "\(TLStoryConfiguration.videoPath!)/\(fileName)")
                try? FileManager.default.removeItem(at: url)
                return url
            }
            
            if type == .photo {
                let fileName = isTemp ? "pic_tmp.png" : "pic_out.png"
                let url = URL.init(fileURLWithPath: "\(TLStoryConfiguration.photoPath!)/\(fileName)")
                try? FileManager.default.removeItem(at: url)
                return url
            }
        }
        return nil
    }
    
    public func reset() {
        movieFile?.audioEncodingTarget = nil
        movieFile = nil
        movieWriter = nil
        image = nil
        audioEnable = true
    }
}

