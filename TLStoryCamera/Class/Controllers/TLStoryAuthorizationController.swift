//
//  TLStoryAuthorizationController.swift
//  TLStoryCamera
//
//  Created by 郭锐 on 2017/5/26.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

protocol TLStoryAuthorizedDelegate: NSObjectProtocol {
    func requestCameraAuthorizeSuccess()
    func requestMicAuthorizeSuccess()
    func requestAllAuthorizeSuccess()
}

class TLStoryAuthorizationController: UIViewController {
    fileprivate var bgBlurView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
    
    fileprivate var titleLabel:UILabel = {
        let lable = UILabel.init()
        lable.text = "允许访问即可拍摄照片和视频"
        lable.textColor = UIColor.init(colorHex: 0xcccccc, alpha: 1)
        lable.font = UIFont.systemFont(ofSize: 18)
        return lable
    }()
    
    fileprivate var openCameraBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.setTitle("启用相机访问权限", for: .normal)
        btn.setTitle("相机访问权限已启用", for: .selected)
        btn.setTitleColor(UIColor.init(colorHex: 0x4797e1, alpha: 1), for: .normal)
        btn.setTitleColor(UIColor.init(colorHex: 0x999999, alpha: 1), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var openMicBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.setTitle("启用麦克风访问权限", for: .normal)
        btn.setTitle("麦克风访问权限已启用", for: .selected)
        btn.setTitleColor(UIColor.init(colorHex: 0x4797e1, alpha: 1), for: .normal)
        btn.setTitleColor(UIColor.init(colorHex: 0x999999, alpha: 1), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var authorizedManager = TLAuthorizedManager()
    
    public weak var delegate:TLStoryAuthorizedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(bgBlurView)
        bgBlurView.frame = self.view.bounds
        
        self.view.addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint.init(x: self.view.width / 2, y: self.view.height / 2 - 45 - titleLabel.height / 2)
        
        openCameraBtn.isSelected = TLAuthorizedManager.checkAuthorization(with: .camera)
        openMicBtn.isSelected = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        self.view.addSubview(openCameraBtn)
        openCameraBtn.sizeToFit()
        openCameraBtn.center = CGPoint.init(x: self.view.width / 2, y: self.view.height / 2 + 20 + openCameraBtn.height / 2)
        
        self.view.addSubview(openMicBtn)
        openMicBtn.sizeToFit()
        openMicBtn.center = CGPoint.init(x: self.view.width / 2, y: openCameraBtn.y + openCameraBtn.height + 30 + openMicBtn.height / 2)
        
        self.openCameraBtn.addTarget(self, action: #selector(openCameraAction), for: .touchUpInside)
        self.openMicBtn.addTarget(self, action: #selector(openMicAction), for: .touchUpInside)
    }
    
    @objc fileprivate func openCameraAction() {
        TLAuthorizedManager.requestAuthorization(with: .camera) { (type, success) in
            if !success {
                return
            }
            self.openCameraBtn.isSelected = true
            self.openCameraBtn.sizeToFit()
            self.openCameraBtn.centerX = self.view.width / 2
            self.delegate?.requestCameraAuthorizeSuccess()
            self.dismiss()
        }
    }
    
    @objc fileprivate func openMicAction() {
        TLAuthorizedManager.requestAuthorization(with: .mic) { (type, success) in
            if !success {
                return
            }
            self.openMicBtn.isEnabled = true
            self.openMicBtn.sizeToFit()
            self.openMicBtn.centerX = self.view.width / 2
            self.delegate?.requestMicAuthorizeSuccess()
            self.dismiss()
        }
    }
    
    func dismiss() {
        if TLAuthorizedManager.checkAuthorization(with: .camera) && TLAuthorizedManager.checkAuthorization(with: .mic) {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.alpha = 0
            }, completion: { (x) in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.delegate?.requestAllAuthorizeSuccess()
            })
        }
    }
}
