//
//  TLStickerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStickerViewZoomProtocol {
    func zoom(out:Bool)
}

extension TLStickerViewZoomProtocol where Self: UIView {
    func zoom(out:Bool) {
        if out {
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = self.transform.scaledBy(x: 0.5, y: 0.5);
                self.alpha = 0.7
            })
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = self.transform.scaledBy(x: 2, y: 2);
                self.alpha = 1
            })
        }
    }
}

protocol TLStickerViewDelegate:NSObjectProtocol {
    func stickerViewBecomeFirstRespond(sticker:UIView)
    func stickerViewDraggingDelete(point:CGPoint,sticker:UIView,isEnd:Bool)
}

class TLStickerView: UIImageView, TLStickerViewZoomProtocol {
    fileprivate static let DefaultWidth = 100
    fileprivate var minWidth:CGFloat = 0
    fileprivate var minHeight:CGFloat = 0
    public weak var delegate:TLStickerViewDelegate?
    fileprivate var lastScale:CGFloat = 1.0
    
    init(img:UIImage, bgView:TLStickerStageView) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: TLStickerView.DefaultWidth, height: TLStickerView.DefaultWidth))
        self.image = img
        
        self.center = CGPoint.init(x: bgView.bounds.width / 2, y: bgView.bounds.height / 2)
        
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
        var newP = CGPoint.init(x: self.center.x + translation.x, y: self.center.y + translation.y)
        newP.y = max(self.bounds.height / 2, newP.y)
        newP.y = min((superview?.bounds.height ?? 0) - self.bounds.height / 2, newP.y)
        newP.x = max(self.bounds.width / 2, newP.x)
        newP.x = min((superview?.bounds.width ?? 0) - self.bounds.width / 2, newP.x)
        self.center = newP
        gesture.setTranslation(CGPoint.zero, in: superview)
        
        self.delegate?.stickerViewDraggingDelete(point: newP, sticker: self, isEnd: gesture.state == .ended || gesture.state == .cancelled)
    }
    
    @objc fileprivate func tap(gesture:UITapGestureRecognizer) {
        let scaleAnim = CABasicAnimation.init(keyPath: "transform.scale")
        scaleAnim.fromValue = self.transform.d
        scaleAnim.toValue = self.transform.d - 0.1
        
        let alphaAnim = CABasicAnimation.init(keyPath: "opacity")
        alphaAnim.fromValue = 1
        alphaAnim.toValue = 0.5
        
        let groupAnim = CAAnimationGroup.init()
        groupAnim.animations = [scaleAnim,alphaAnim]
        groupAnim.autoreverses = true
        groupAnim.isRemovedOnCompletion = true
        groupAnim.duration = 0.1
        
        self.layer.add(groupAnim, forKey: nil)
        
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
    }
    
    @objc fileprivate func pinche(pinche:UIPinchGestureRecognizer) {
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
        
        if(pinche.state == .ended) {
            lastScale = 1.0
            return
        }
        
        let scale = 1.0 - (lastScale - pinche.scale)
        
        let currentTransform = self.transform
        let newTransform = currentTransform.scaledBy(x: scale, y: scale)
        
        self.transform = newTransform
        lastScale = pinche.scale
    }
    
    @objc fileprivate func rotate(rotate:UIRotationGestureRecognizer) {
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
        self.transform = self.transform.rotated(by: rotate.rotation)
        rotate.rotation = 0
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStickerView: UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) || gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return false
        }
        return true
    }
}
