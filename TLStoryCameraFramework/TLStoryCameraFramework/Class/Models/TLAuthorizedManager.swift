//
//  TLAuthorizedManager.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/26.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import Photos

typealias AuthorizedCallback = (TLAuthorizedManager.AuthorizedType, Bool) -> Void

class TLAuthorizedManager: NSObject {
    public enum AuthorizedType {
        case mic
        case camera
        case album
    }
    
    public static func requestAuthorization(with type:AuthorizedType, callback:@escaping AuthorizedCallback) {
        if type == .mic {
            self.requestMicAuthorizationStatus(callback)
        }
        if type == .camera {
            self.requestCameraAuthorizationStatus(callback)
        }
        if type == .album {
            self.requestAlbumAuthorizationStatus(callback)
        }
    }
    
    public static func checkAuthorization(with type:AuthorizedType) -> Bool {
        if type == .mic {
            return AVAudioSession.sharedInstance().recordPermission() == .granted
        }
        if type == .camera {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        }
        if type == .album {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        return false
    }
    
    public static func openAuthorizationSetting() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
    fileprivate static func requestMicAuthorizationStatus(_ callabck:@escaping AuthorizedCallback) {
        let status = AVAudioSession.sharedInstance().recordPermission()
        if status == .granted {
            DispatchQueue.main.async {
                callabck(.mic, true)
            }
        }else if status == .denied {
            DispatchQueue.main.async {
                callabck(.mic, false)
            }
            self.openAuthorizationSetting()
        }else{
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                DispatchQueue.main.async {
                    callabck(.mic, granted)
                }
            })
        }
    }
    
    fileprivate static func requestCameraAuthorizationStatus(_ callabck:@escaping AuthorizedCallback) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == .authorized {
            DispatchQueue.main.async {
                callabck(.camera, true)
            }
        }else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                DispatchQueue.main.async {
                    callabck(.camera, granted)
                }
            })
        }else if (status == .denied) {
            DispatchQueue.main.async {
                callabck(.camera, false)
                self.openAuthorizationSetting()
            }
        }
    }
    
    fileprivate static func requestAlbumAuthorizationStatus(_ callabck:@escaping AuthorizedCallback) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            DispatchQueue.main.async {
                callabck(.album, true)
            }
        }else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (granted) in
                DispatchQueue.main.async {
                    callabck(.album, granted == .authorized)
                }
            })
        }else if status == .denied || status == .restricted {
            DispatchQueue.main.async {
                callabck(.album, false)
            }
            self.openAuthorizationSetting()
        }
    }
}
