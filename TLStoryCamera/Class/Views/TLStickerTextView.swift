//
//  TLStickerTextView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStickerTextViewDelegate: TLStickerViewDelegate {
    func stickerTextViewEditing(sticker:TLStickerTextView)
}

class TLStickerTextView: UILabel, TLStickerViewZoomProtocol {
    public weak var delegate:TLStickerTextViewDelegate?
    
    fileprivate var lastPosition:CGPoint = CGPoint.zero
    
    fileprivate var lastScale:CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = UIFont.boldSystemFont(ofSize: TLStoryConfiguration.defaultTextWeight)
        self.textColor = UIColor.white
        self.backgroundColor = UIColor.clear
        self.textAlignment = .center
        self.isUserInteractionEnabled = true
        self.numberOfLines = 0
        
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
    }
    
    @objc fileprivate func pan(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let newP = CGPoint.init(x: self.center.x + translation.x, y: self.center.y + translation.y)
        self.center = newP
        gesture.setTranslation(CGPoint.zero, in: superview)
        
        self.delegate?.stickerViewDraggingDelete(point: newP, sticker: self, isEnd: gesture.state == .ended)
    }
    
    @objc fileprivate func tap(tap:UITapGestureRecognizer) {
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
        self.delegate?.stickerTextViewEditing(sticker: self)
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
    
    internal override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStickerTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) || gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return false
        }
        return true
    }
}
