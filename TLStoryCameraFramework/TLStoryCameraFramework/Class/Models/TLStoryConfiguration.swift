//
//  TLStoryConfiguration.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class TLStoryConfiguration: NSObject {
    //是否开启美颜
    public static let openBeauty:Bool = false
    
    //最大录像时间
    public static let maxRecordingTime:TimeInterval = 10.0 * 60
    
    //最短录像时间（<此时间都是拍照）
    public static let minRecordingTime:TimeInterval = 30
    
    //最大镜头焦距
    public static let maxVideoZoomFactor:CGFloat = 20
    
    //视频输入
    public static let videoSetting:[String : Any] = [
        AVVideoCodecKey : AVVideoCodecH264,
        AVVideoWidthKey : 720,
        AVVideoHeightKey: 1280,
        AVVideoCompressionPropertiesKey:
            [
                AVVideoProfileLevelKey : AVVideoProfileLevelH264Main31,
                AVVideoAllowFrameReorderingKey : false,
                //码率
                AVVideoAverageBitRateKey : 720 * 1280 * 3
        ]
    ]
    
    //音频输入
    public static let audioSetting:[String : Any] = [
        AVFormatIDKey : kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 2,
        AVSampleRateKey : 16000,
        AVEncoderBitRateKey : 32000
    ]
    
    //视频采集格式
    public static let videoFileType:String = AVFileType.mov.rawValue
    
    //视频采集尺寸
    public static let captureSessionPreset:String = AVCaptureSession.Preset.hd1280x720.rawValue
    
    //输出的视频尺寸
    public static let outputVideoSize:CGSize = CGSize.init(width: 720, height: 1280)
    
    //输出的图片尺寸
    public static let outputPhotoSize:CGSize = CGSize.init(width: 1080, height: 1920)
    
    //视频路径
    public static let videoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyvideo")
    
    //图片路径
    public static let photoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyphoto")

    //最大笔触
    public static let maxDrawLineWeight:CGFloat = 30
    //最小笔触
    public static let minDrawLineWeight:CGFloat = 5
    //默认笔触
    public static let defaultDrawLineWeight:CGFloat = 5
    
    //最大字体大小
    public static let maxTextWeight:CGFloat = 60
    //最小字体大小
    public static let minTextWeight:CGFloat = 12
    //默认字体大小
    public static let defaultTextWeight:CGFloat = 30
    
    //导出水印
    public static let watermarkImage:UIImage? = UIImage.init(named: "watermark")
    //导出水印位置
    public static let watermarkPosition:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 10)
}
