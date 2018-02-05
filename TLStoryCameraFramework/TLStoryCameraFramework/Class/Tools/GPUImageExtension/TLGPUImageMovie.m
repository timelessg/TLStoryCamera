//
//  TLGPUImageMovie.m
//  TLStoryCamera
//
//  Created by garry on 2017/9/14.
//  Copyright © 2017年 com.garry. All rights reserved.
//

#import "TLGPUImageMovie.h"

@implementation TLGPUImageMovie
-(void)startProcessing {
    [super startProcessing];
    
    if (self.startProcessingCallback) {
        self.startProcessingCallback();
    }
}
@end
