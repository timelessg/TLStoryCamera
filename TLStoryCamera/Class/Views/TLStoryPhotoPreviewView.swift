//
//  TLStoryPhotoPreviewView.swift
//  TLStoryCamera
//
//  Created by garry on 2017/9/15.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import GPUImage

class TLStoryPhotoPreviewView: UIView {
    public var gpuPicture:GPUImagePicture? = nil
    
    fileprivate var gpuView:GPUImageView? = nil
    
    deinit {
        gpuOutput?.removeAllTargets()
        gpuPicture?.removeAllTargets()
    }
    
    init(frame: CGRect, image:UIImage) {
        super.init(frame: frame)
        
        gpuView = GPUImageView.init(frame: self.bounds)
        gpuView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        self.addSubview(gpuView!)
        
        gpuPicture = GPUImagePicture.init(image: image)
        
        gpuPicture!.addTarget(gpuView)
        
        gpuPicture?.processImage()
    }
    
    public func switchWith(filter:GPUImageCustomLookupFilter?) {
        gpuPicture?.removeAllTargets()
        
        if let f = filter {
            gpuPicture?.addTarget(f)
            f.addTarget(gpuView!)
        }else {
            gpuPicture!.addTarget(gpuView)
        }
        gpuPicture?.processImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
