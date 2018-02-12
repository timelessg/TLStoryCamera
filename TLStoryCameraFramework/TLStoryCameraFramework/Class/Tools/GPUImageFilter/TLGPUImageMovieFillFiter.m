//
//  TLGPUImageMovieFillFiter.m
//  TLStoryCamera
//
//  Created by garry on 2018/2/12.
//  Copyright © 2018年 com.garry. All rights reserved.
//

#import "TLGPUImageMovieFillFiter.h"

@implementation TLGPUImageMovieFillFiter
-(void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    GLfloat squareVertices[8];
    
    [self handleSquareVertices:squareVertices];
    
    [self renderToTextureWithVertices:squareVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}
- (void)handleSquareVertices:(GLfloat *)squareVertices {
    CGFloat heightScaling, widthScaling;
    
    CGSize currentViewSize = [UIScreen mainScreen].bounds.size;
    
    CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(inputTextureSize, [UIScreen mainScreen].bounds);
    
    switch(_fillMode)
    {
        case kGPUImageMovieFillModeStretch:
        {
            widthScaling = 1.0;
            heightScaling = 1.0;
        }; break;
        case kGPUImageMovieFillModePreserveAspectRatio:
        {
            widthScaling = insetRect.size.width / currentViewSize.width;
            heightScaling = insetRect.size.height / currentViewSize.height;
        }; break;
        case kGPUImageMovieFillModePreserveAspectRatioAndFill:
        {
            widthScaling = currentViewSize.height / insetRect.size.height;
            heightScaling = currentViewSize.width / insetRect.size.width;
        }; break;
    }
    
    squareVertices[0] = -widthScaling;
    squareVertices[1] = -heightScaling;
    squareVertices[2] = widthScaling;
    squareVertices[3] = -heightScaling;
    squareVertices[4] = -widthScaling;
    squareVertices[5] = heightScaling;
    squareVertices[6] = widthScaling;
    squareVertices[7] = heightScaling;
}
@end
