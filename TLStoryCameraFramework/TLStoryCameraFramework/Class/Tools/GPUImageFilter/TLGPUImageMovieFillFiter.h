//
//  TLGPUImageMovieFillFiter.h
//  TLStoryCamera
//
//  Created by garry on 2018/2/12.
//  Copyright © 2018年 com.garry. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>

typedef NS_ENUM(NSUInteger, GPUImageMovieFillModeType) {
    kGPUImageMovieFillModeStretch,                       // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
    kGPUImageMovieFillModePreserveAspectRatio,           // Maintains the aspect ratio of the source image, adding bars of the specified background color
    kGPUImageMovieFillModePreserveAspectRatioAndFill     // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
};

@interface TLGPUImageMovieFillFiter : GPUImageFilter
@property(readwrite, nonatomic) GPUImageMovieFillModeType fillMode;
@end
