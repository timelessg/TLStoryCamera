//
//  TLStoryOverlayControlView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/31.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryOverlayControlDelegate: NSObjectProtocol {
    func storyOverlayCameraRecordingStart()
    func storyOverlayCameraRecordingFinish(type:TLStoryType)
    func storyOverlayCameraZoom(distance:CGFloat)
    func storyOverlayCameraFlashChange() -> AVCaptureTorchMode
    func storyOverlayCameraSwitch()
    func storyOverlayCameraFocused(point:CGPoint)
}

class TLStoryOverlayControlView: UIView {
    public weak var delegate:TLStoryOverlayControlDelegate?
    
    fileprivate lazy var cameraBtn = TLStoryCameraButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
    
    fileprivate lazy var flashBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_flashlight_auto"), for: .normal)
        btn.addTarget(self, action: #selector(flashAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var switchBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_cam_turn"), for: .normal)
        btn.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate var photoLibraryHintView:TLPhotoLibraryHintView?
    
    fileprivate var tapGesture:UITapGestureRecognizer?
    
    fileprivate var doubleTapGesture:UITapGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cameraBtn.center = CGPoint.init(x: self.center.x, y: self.bounds.height - 52 - 40)
        cameraBtn.delegete = self
        addSubview(cameraBtn)
        
        flashBtn.sizeToFit()
        flashBtn.center = CGPoint.init(x: cameraBtn.centerX - 100, y: cameraBtn.centerY)
        addSubview(flashBtn)
        
        switchBtn.sizeToFit()
        switchBtn.center = CGPoint.init(x: cameraBtn.centerX + 100, y: cameraBtn.centerY)
        addSubview(switchBtn)
        
        photoLibraryHintView = TLPhotoLibraryHintView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        photoLibraryHintView?.center = CGPoint.init(x: self.self.width / 2, y: self.height - 25)
        addSubview(photoLibraryHintView!)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        tapGesture?.delegate = self
        tapGesture!.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture!)
        
        doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction))
        doubleTapGesture?.delegate = self
        doubleTapGesture!.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture!)
        
        tapGesture!.require(toFail: doubleTapGesture!)
    }
    
    public func dismiss() {
        self.isHidden = true
        self.cameraBtn.reset()
    }
    
    public func display() {
        self.isHidden = false
        self.cameraBtn.show()
    }
    
    public func beginHintAnim () {
        photoLibraryHintView?.startAnim()
    }
    
    @objc fileprivate func tapAction(sender:UITapGestureRecognizer) {
        let point = sender.location(in: self)
        self.delegate?.storyOverlayCameraFocused(point: point)
    }
    
    @objc fileprivate func doubleTapAction(sender:UITapGestureRecognizer) {
        self.delegate?.storyOverlayCameraSwitch()
    }
    
    @objc fileprivate func flashAction(sender: UIButton) {
        let mode = self.delegate?.storyOverlayCameraFlashChange()
        let imgs = [AVCaptureTorchMode.on:#imageLiteral(resourceName: "story_publish_icon_flashlight_on"),
                    AVCaptureTorchMode.off:#imageLiteral(resourceName: "story_publish_icon_flashlight_off"),
                    AVCaptureTorchMode.auto:#imageLiteral(resourceName: "story_publish_icon_flashlight_auto")]
        sender.setImage(imgs[mode!], for: .normal)
    }
    
    @objc fileprivate func switchAction(sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.transform = sender.transform.rotated(by: CGFloat(Double.pi))
        }) { (x) in
            self.delegate?.storyOverlayCameraSwitch()
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryOverlayControlView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        if self.cameraBtn.frame.contains(point) {
            return false
        }
        return true
    }
}

extension TLStoryOverlayControlView: TLStoryCameraButtonDelegate {
    internal func cameraStart(hoopButton: TLStoryCameraButton) {
        self.delegate?.storyOverlayCameraRecordingStart()
        photoLibraryHintView?.isHidden = true
    }
    
    internal func cameraDrag(hoopButton: TLStoryCameraButton, offsetY: CGFloat) {
        self.delegate?.storyOverlayCameraZoom(distance: offsetY)
    }
    
    internal func cameraComplete(hoopButton: TLStoryCameraButton, type: TLStoryType) {
        self.delegate?.storyOverlayCameraRecordingFinish(type: type)
        self.isHidden = true
    }
}


class TLPhotoLibraryHintView: UIView {
    fileprivate lazy var hintLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(colorHex: 0xffffff, alpha: 0.8)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "向上滑动打开相册"
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.7
        return label
    }()
    
    fileprivate lazy var arrowIco = UIImageView.init(image: #imageLiteral(resourceName: "story_icon_up"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(hintLabel)
        hintLabel.sizeToFit()
        hintLabel.center = CGPoint.init(x: self.width / 2, y: self.height - 10 - hintLabel.height / 2)
        
        self.addSubview(arrowIco)
        arrowIco.sizeToFit()
        arrowIco.center = CGPoint.init(x: self.width / 2, y: 10 + arrowIco.height / 2)
    }
    
    public func startAnim() {
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat,.autoreverse], animations: {
            self.arrowIco.centerY = 5 + self.arrowIco.height / 2
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
