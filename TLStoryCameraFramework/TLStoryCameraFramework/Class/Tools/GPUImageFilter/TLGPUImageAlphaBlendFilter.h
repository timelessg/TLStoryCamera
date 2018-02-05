//
//  TLGPUImageAlphaBlendFilter.h
//  TLStoryCamera
//
//  Created by garry on 2017/6/5.
//  Copyright © 2017年 com.garry. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>

@interface TLGPUImageAlphaBlendFilter : GPUImageTwoInputFilter
{
    GLint mixUniform;
}

// Mix ranges from 0.0 (only image 1) to 1.0 (only image 2), with 1.0 as the normal level
@property(readwrite, nonatomic) CGFloat mix;

@end
