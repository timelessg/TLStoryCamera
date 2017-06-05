//
//  TLGPUImageAlphaBlendFilter.m
//  TLStoryCamera
//
//  Created by garry on 2017/6/5.
//  Copyright © 2017年 com.garry. All rights reserved.
//

#import "TLGPUImageAlphaBlendFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageAlphaBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float mixturePercent;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     lowp float alphaDivisor = textureColor2.a + step(textureColor2.a, 0.0); // Protect against a divide-by-zero blacking out things in the output
     gl_FragColor = vec4(mix(textureColor.rgb, textureColor2.rgb / alphaDivisor, mixturePercent * textureColor2.a), textureColor.a);
 }
 );
#else
NSString *const kGPUImageAlphaBlendFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float mixturePercent;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     gl_FragColor = vec4(mix(textureColor.rgb, textureColor2.rgb, textureColor2.a * mixturePercent), textureColor.a);
 }
 );
#endif

@implementation TLGPUImageAlphaBlendFilter
@synthesize mix = _mix;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageAlphaBlendFragmentShaderString]))
    {
        return nil;
    }
    
    mixUniform = [filterProgram uniformIndex:@"mixturePercent"];
    self.mix = 0.5;
    
    return self;
}


#pragma mark -
#pragma mark Accessors

- (void)setMix:(CGFloat)newValue;
{
    _mix = newValue;
    
    [self setFloat:_mix forUniform:mixUniform program:filterProgram];
}

@end
