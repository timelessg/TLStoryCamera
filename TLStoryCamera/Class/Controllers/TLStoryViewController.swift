//
//  TLStoryCameraViewController.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

public enum TLStoryType {
    case video
    case photo
}

public protocol TLStoryViewDelegate: NSObjectProtocol {
    func storyViewRecording(running:Bool)
    func storyViewDidPublish(type:TLStoryType, url:URL?)
}

public class TLStoryViewController: UIViewController {
    public weak var delegate:TLStoryViewDelegate?

    fileprivate var containerView = UIView.init()
    
    fileprivate var bottomImagePicker:TLStoryBottomImagePickerView?
    
    fileprivate var captureView:TLStoryCapturePreviewView?
    
    fileprivate var outputView:TLStoryOverlayOutputView?
    
    fileprivate var editContainerView:TLStoryEditContainerView?
    
    fileprivate var controlView:TLStoryOverlayControlView?
    
    fileprivate var editView:TLStoryOverlayEditView?
    
    fileprivate var textStickerView:TLStoryOverlayTextStickerView?
    
    fileprivate var imageStickerView:TLStoryOverlayImagePicker?
    
    fileprivate var blurCoverView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    
    fileprivate var swipeUp:UISwipeGestureRecognizer?
    
    fileprivate var swipeDown:UISwipeGestureRecognizer?
    
    fileprivate var tapGesture:UITapGestureRecognizer?
    
    fileprivate var doubleTapGesture:UITapGestureRecognizer?
    
    fileprivate var output = TLStoryOutput.init()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.isUserInteractionEnabled = true
        
        bottomImagePicker = TLStoryBottomImagePickerView.init(frame: CGRect.init(x: 0, y: self.view.height - 165, width: self.view.width, height: 165))
        bottomImagePicker?.delegate = self
        self.view.addSubview(bottomImagePicker!)
        
        view.addSubview(containerView)
        containerView.frame = self.view.bounds
        
        captureView = TLStoryCapturePreviewView.init(frame: self.view.bounds)
        containerView.addSubview(captureView!)
        
        outputView = TLStoryOverlayOutputView.init(frame: self.view.bounds)
        outputView!.isHidden = true
        containerView.addSubview(outputView!)
        
        editContainerView = TLStoryEditContainerView.init(frame: self.view.bounds)
        editContainerView!.delegate = self
        outputView!.addSubview(editContainerView!)
        
        controlView = TLStoryOverlayControlView.init(frame: self.view.bounds)
        controlView!.delegate = self
        controlView!.isHidden = true
        containerView.addSubview(controlView!)
        
        editView = TLStoryOverlayEditView.init(frame: self.view.bounds)
        editView!.delegate = self
        editView!.isHidden = true
        containerView.addSubview(editView!)
        
        textStickerView = TLStoryOverlayTextStickerView.init(frame: self.view.bounds)
        textStickerView!.delegate = self
        textStickerView!.isHidden = true
        containerView.addSubview(textStickerView!)
        
        imageStickerView = TLStoryOverlayImagePicker.init(frame: self.view.bounds)
        imageStickerView?.delegate = self
        imageStickerView!.isHidden = true
        containerView.addSubview(imageStickerView!)
        
        containerView.addSubview(blurCoverView)
        blurCoverView.isUserInteractionEnabled = true
        blurCoverView.frame = self.view.bounds
        
        swipeUp = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeAction))
        swipeUp!.direction = .up
        self.controlView?.addGestureRecognizer(swipeUp!)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        tapGesture!.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture!)
        
        doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction))
        doubleTapGesture!.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture!)
        
        tapGesture!.require(toFail: doubleTapGesture!)
        
        self.checkAuthorized()
    }
    
    public func resumeCamera(open:Bool) {
        self.captureView!.cameraSwitch(open: open)

        if open {
            UIView.animate(withDuration: 0.25, animations: {
                self.blurCoverView.alpha = 0
            }, completion: { (x) in
                if x {
                    self.blurCoverView.isHidden = true
                }
            })
        }else {
            self.blurCoverView.alpha = 1
            self.blurCoverView.isHidden = false
        }
    }
    
    @objc fileprivate func swipeAction(sender:UISwipeGestureRecognizer) {
        if sender.direction == .up && self.containerView.y == 0 {
            self.bottomImagePicker(hidden: false)
            return
        }
        
        if sender.direction == .down {
            self.bottomImagePicker(hidden: true)
            return
        }
    }
    
    @objc fileprivate func tapAction(sender:UITapGestureRecognizer) {
        let point = sender.location(in: self.view)
        self.captureView?.focus(point: point)
    }
    
    @objc fileprivate func doubleTapAction(sender:UITapGestureRecognizer) {
        self.captureView?.rotateCamera()
    }
    
    fileprivate func bottomImagePicker(hidden:Bool) {
        if !hidden {
            blurCoverView.isHidden = false
            blurCoverView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.blurCoverView.alpha = 1
                self.containerView.y -= 165
            }) { (x) in
                self.swipeDown = UISwipeGestureRecognizer.init(target: self, action: #selector(self.swipeAction))
                self.swipeDown!.direction = .down
                self.blurCoverView.addGestureRecognizer(self.swipeDown!)
                self.bottomImagePicker?.loadPhotos()
            }
        }else {
            blurCoverView.alpha = 1
            UIView.animate(withDuration: 0.25, animations: {
                self.blurCoverView.alpha = 0
                self.containerView.y = 0
            }, completion: { (x) in
                self.blurCoverView.isHidden = true
                self.blurCoverView.alpha = 1
                self.blurCoverView.removeGestureRecognizer(self.swipeDown!)
            })
        }
        self.delegate?.storyViewRecording(running: !hidden)
    }
    
    fileprivate func checkAuthorized() {
        let cameraAuthorization = TLAuthorizedManager.checkAuthorization(with: .camera)
        let micAuthorization = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        if cameraAuthorization && micAuthorization {
            if cameraAuthorization {
                self.cameraStart()
            }
            if micAuthorization {
                captureView!.configAudioRecording()
            }
            controlView!.isHidden = false
        }else {
            let authorizedVC = TLStoryAuthorizationController()
            authorizedVC.view.frame = self.view.bounds
            authorizedVC.delegate = self
            self.view.addSubview(authorizedVC.view)
            self.addChildViewController(authorizedVC)
        }
    }
    
    fileprivate func cameraStart() {
        captureView!.initCamera()
        captureView!.configVideoRecording()
        captureView!.startCapture()
    }
    
    fileprivate func previewDispay(url:URL, type:TLStoryType) {
        self.outputView!.isHidden = false
        self.output.type = type
        self.output.url = url
        self.editView?.dispaly()
        self.editView?.setAudioEnableBtn(hidden: type == .photo)
        self.controlView?.dismiss()
        self.outputView?.display(with: url, type: type)
        self.delegate?.storyViewRecording(running: true)
    }
    
    fileprivate func previewDismiss() {
        self.outputView!.isHidden = true
        self.editView?.dismiss()
        self.outputView?.reset()
        self.editContainerView?.reset()
        self.textStickerView?.reset()
        self.controlView?.display()
        self.captureView?.resumeCamera()
        self.delegate?.storyViewRecording(running: false)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}

extension TLStoryViewController: TLStoryOverlayControlDelegate {
    internal func storyOverlayCameraRecordingStart() {
        captureView!.configVideoRecording()
        captureView!.configAudioRecording()
        captureView!.startRecording()
    }
    
    internal func storyOverlayCameraSwitch() {
        captureView!.rotateCamera()
    }
    
    internal func storyOverlayCameraZoom(distance: CGFloat) {
        captureView!.camera(distance: distance)
    }
    
    internal func storyOverlayCameraRecordingFinish(type: TLStoryType) {
        if type == .photo {
            self.captureView!.capturePhoto(complete: { [weak self] (x) in
                if let url = x {
                    self?.previewDispay(url: url, type: .photo)
                }
            })
        }else {
            self.captureView!.finishRecording(complete: { [weak self] (x) in
                if let url = x {
                    self?.previewDispay(url: url, type: .video)
                }
            })
        }
    }
    internal func storyOverlayCameraFlashChange() -> AVCaptureTorchMode {
        return self.captureView!.flashStatusChange()
    }
}

extension TLStoryViewController: TLStoryOverlayEditViewDelegate {
    internal func storyOverlayEditPublish() {
        guard let container = self.editContainerView?.getScreenshot() else {
            return
        }
        
        self.editView?.dismiss()
        self.output.output(container: container) { [weak self] (url, type) in
            self?.editView?.dispaly()
            self?.delegate?.storyViewDidPublish(type: type, url: url)
            self?.previewDismiss()
        }
    }
    
    internal func storyOverlayEditSave() {
        let block:((Void) -> Void) = { () in
            guard let container = self.editContainerView?.getScreenshot() else {
                return
            }
            
            self.editView?.dismiss()
            self.output.saveToAlbum(container: container) { (x) in
                self.editView?.dispaly()
            }
        }
        
        guard TLAuthorizedManager.checkAuthorization(with: .album) else {
            TLAuthorizedManager.requestAuthorization(with: .album, callback: { (type, success) in
                if success {
                    block()
                }
            })
            return
        }
        
        block()
    }
    
    internal func storyOverlayEditTextEditerDisplay() {
        textStickerView?.show(sticker: nil)
    }
    
    internal func storyOverlayEditStickerPickerDisplay() {
        imageStickerView?.isHidden = false
        imageStickerView?.display()
    }
    
    internal func storyOverlayEditDoodleEditable() {
        self.editContainerView?.benginDrawing()
    }
    
    internal func storyOverlayEditClose() {
        self.previewDismiss()
    }
    
    internal func storyOverlayEditAudio(enable: Bool) {
        self.output.audioEnable = enable
        self.outputView?.playerAudio(enable: enable)
    }
}

extension TLStoryViewController: TLStoryOverlayTextStickerViewDelegate {
    internal func textEditerDidCompleteEdited(sticker: TLStoryTextSticker?) {
        if let s = sticker {
            self.editContainerView?.add(textSticker: s)
        }
        editView?.dispaly()
    }
}

extension TLStoryViewController: TLStoryOverlayImagePickerDelegate {
    internal func storyOverlayImagePickerDismiss() {
        self.imageStickerView?.isHidden = true
        editView?.dispaly()
    }

    internal func storyOverlayImagePickerDidSelected(img: UIImage) {
        self.editContainerView?.add(img: img)
    }
}

extension TLStoryViewController: TLStoryEditContainerViewDelegate {
    internal func storyEditContainerSticker(editing: Bool) {
        if editing {
            self.editView?.dismiss()
        }else {
            self.editView?.dispaly()
        }
    }

    internal func storyEditContainerEndDrawing() {
        self.editView?.dispaly()
    }

    internal func storyEditContainerTextStickerBeEditing(sticker: TLStoryTextSticker) {
        self.editView?.dismiss()
        self.textStickerView?.show(sticker: sticker)
    }
}

extension TLStoryViewController: TLStoryBottomImagePickerViewDelegate {
    internal func photoLibraryPickerDidSelect(url: URL, type:TLStoryType) {
        self.bottomImagePicker(hidden: true)
        self.previewDispay(url: url, type: type)
    }
}

extension TLStoryViewController: TLStoryAuthorizedDelegate {
    internal func requestMicAuthorizeSuccess() {
        captureView!.configAudioRecording()
    }
    
    internal func requestCameraAuthorizeSuccess() {
        self.cameraStart()
    }
    
    internal func requestAllAuthorizeSuccess() {
        self.controlView!.isHidden = false
    }
}
