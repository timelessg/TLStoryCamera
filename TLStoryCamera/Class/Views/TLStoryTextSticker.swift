//
//  TLStoryTextSticker.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryStickerProtocol {
    func zoom(out:Bool)
    func beginScaleAnim()
}

extension TLStoryStickerProtocol where Self: UIView {
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
    
    func beginScaleAnim() {
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
    }
}

protocol TLStoryStickerDelegate:NSObjectProtocol {
    func stickerViewBecomeFirstRespond(sticker:UIView)
    func stickerView(handing:Bool)
    func stickerViewDraggingDelete(point:CGPoint,sticker:UIView,isEnd:Bool)
}

protocol TLStoryTextStickerDelegate: TLStoryStickerDelegate {
    func storyTextStickerEditing(sticker:TLStoryTextSticker)
}

class TLStoryTextSticker: UIView, TLStoryStickerProtocol {
    public weak var delegate:TLStoryTextStickerDelegate?
    
    fileprivate var lastPosition:CGPoint = CGPoint.zero
    
    fileprivate var lastScale:CGFloat = 1.0

    public      var textView:TLStoryTextView = {
        let textview = TLStoryTextView()
        textview.font = UIFont.boldSystemFont(ofSize: TLStoryConfiguration.defaultTextWeight)
        textview.textColor = UIColor.white
        textview.backgroundColor = UIColor.clear
        textview.textAlignment = .center
        textview.layoutManager.allowsNonContiguousLayout = false
        textview.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        textview.autocorrectionType = .no
        textview.isScrollEnabled = false
        return textview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        textView.frame = self.bounds
        self.addSubview(textView)
        
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
        
        self.delegate?.stickerViewDraggingDelete(point: newP, sticker: self, isEnd: gesture.state == .ended || gesture.state == .cancelled)
        self.delegate?.stickerView(handing: gesture.state == .began || gesture.state == .changed)
    }
    
    @objc fileprivate func tap(tap:UITapGestureRecognizer) {
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
        self.delegate?.storyTextStickerEditing(sticker: self)        
    }
    
    @objc fileprivate func pinche(pinche:UIPinchGestureRecognizer) {
        
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
        self.delegate?.stickerView(handing: pinche.state == .began || pinche.state == .changed)
    }
    
    @objc fileprivate func rotate(rotate:UIRotationGestureRecognizer) {
        self.transform = self.transform.rotated(by: rotate.rotation)
        rotate.rotation = 0
        
        self.delegate?.stickerViewBecomeFirstRespond(sticker: self)
        self.delegate?.stickerView(handing: rotate.state == .began || rotate.state == .changed)
    }
    
    internal override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        self.textView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryTextSticker: UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) || gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return false
        }
        return true
    }
}

class TLStoryTextView: UITextView, UIGestureRecognizerDelegate {
    
}
