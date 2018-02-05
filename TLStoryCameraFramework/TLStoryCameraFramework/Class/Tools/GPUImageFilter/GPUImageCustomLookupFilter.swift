//
//  GPUImageCustomLookupFilter.swift
//  TLStoryCamera
//
//  Created by garry on 2017/9/14.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import GPUImage

class GPUImageCustomLookupFilter: GPUImageFilterGroup {
    var lookupImageSource: GPUImagePicture?
    
    init(lookupImageNamed: String) {
        super.init()
        self.lookupImageSource = GPUImagePicture.init(image: UIImage.imageWithFilter(named: lookupImageNamed))
        let lookupFilter = GPUImageLookupFilter.init()
        self.addTarget(lookupFilter)
        self.lookupImageSource?.addTarget(lookupFilter, atTextureLocation: 1)
        self.lookupImageSource?.processImage()
        self.initialFilters = [lookupFilter]
        self.terminalFilter = lookupFilter
    }
}
