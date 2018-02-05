//
//  TLStoryImageSticker.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class TLStoryImageSticker: UIImageView, TLStoryStickerProtocol {
    public weak var delegate:TLStoryStickerDelegate?

    fileprivate let DefaultWidth = 100
    
    fileprivate var minWidth:CGFloat = 0
    
    fileprivate var minHeight:CGFloat = 0
    
    fileprivate var lastScale:CGFloat = 1.0
    
    init(img:UIImage) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: self.DefaultWidth, height: self.DefaultWidth))
        self.image = img
                
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pan))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        
        let pincheGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pinche))
        pincheGesture.delegate = self
        self.addGestureRecognizer(pincheGesture)
        
        let rotateGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(rotate))
        rotateGesture.delegate = self
        self.addGestureRecognizer(rotateGesture)
        
        self.isUserInteractionEnabled = true
        
        minWidth = self.bounds.width * 0.5
        minHeight = self.bounds.height * 0.5
    }
    
    @objc fileprivate func pan(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let point = gesture.location(in: self.superview)
        let newP = CGPoint.init(x: self.center.x + translation.x, y: self.center.y + translation.y)
        self.center = newP
        gesture.setTranslation(CGPoint.zero, in: superview)
        
        self.delegate?.stickerViewDraggingDelete(point: point, sticker: self, isEnd: gesture.state == .ended || gesture.state == .cancelled)
        self.delegate?.stickerView(handing: gesture.state == .began || gesture.state == .changed)
    }
    
    @objc fileprivate func tap(gesture:UITapGestureRecognizer) {
        self.beginScaleAnim()
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
    }
    
    @objc fileprivate func pinche(pinche:UIPinchGestureRecognizer) {
        self.delegate?.stickerView(handing: pinche.state == .began || pinche.state == .changed)

        if(pinche.state == .ended) {
            lastScale = 1.0
            return
        }
        
        let scale = 1.0 - (lastScale - pinche.scale)
        
        let currentTransform = self.transform
        let newTransform = currentTransform.scaledBy(x: scale, y: scale)
        
        self.transform = newTransform
        lastScale = pinche.scale
        
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
    }
    
    @objc fileprivate func rotate(rotate:UIRotationGestureRecognizer) {
        self.transform = self.transform.rotated(by: rotate.rotation)
        rotate.rotation = 0
        
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
        self.delegate?.stickerView(handing: rotate.state == .began || rotate.state == .changed)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryImageSticker: UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) || gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return false
        }
        return true
    }
}
