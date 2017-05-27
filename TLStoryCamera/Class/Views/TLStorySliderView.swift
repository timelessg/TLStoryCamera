//
//  TLStorySliderView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLSliderDelegate: NSObjectProtocol {
    func sliderDragging(ratio:CGFloat)
}

class TLStorySliderView: UIView {
    fileprivate var blockView:UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        return view
    }()
    
    fileprivate var sliderLayer:CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.fillColor = UIColor.init(colorHex: 0xffffff, alpha: 1).cgColor
        layer.opacity = 0.3
        return layer
    }()
    
    public weak var delegate:TLSliderDelegate?
    
    fileprivate var path = UIBezierPath.init()
    
    fileprivate var toPath = UIBezierPath.init()
    
    fileprivate var isBeginAnim = false
    
    public      var ratio:CGFloat = 50 / 180
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
        self.layer.addSublayer(sliderLayer)
        
        path.move(to: CGPoint.init(x: self.width / 2 - 0.5, y: self.height - 15))
        path.addLine(to: CGPoint.init(x: self.width / 2 - 2.5, y: 15))
        path.addLine(to: CGPoint.init(x: self.width / 2 + 2.5, y: 15))
        path.addLine(to: CGPoint.init(x: self.width / 2 + 0.5, y: self.height - 15))
        path.close()
        self.sliderLayer.path = path.cgPath
        
        toPath.move(to: CGPoint.init(x: self.width / 2 - 0.5, y: self.height - 15))
        toPath.addLine(to: CGPoint.init(x: self.width / 2 - 2.5 - 6, y: 15))
        toPath.addLine(to: CGPoint.init(x: self.width / 2 + 2.5 + 6, y: 15))
        toPath.addLine(to: CGPoint.init(x: self.width / 2 + 0.5, y: self.height - 15))
        toPath.close()
        
        self.addSubview(blockView)
        blockView.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        blockView.center = CGPoint.init(x: self.width / 2, y: self.height - 50)
        self.updateRatio(centerY: blockView.centerY)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panAction))
        blockView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    
    public func updateRatio(centerY:CGFloat) {
        self.ratio = (self.height - centerY) / (self.height)
        self.delegate?.sliderDragging(ratio: self.ratio)
    }
    
    public func setDefaultValue(type:TLStoryDeployType) {
        if type == .text {
            let ratio = (TLStoryConfiguration.defaultTextWeight - TLStoryConfiguration.minTextWeight) / (TLStoryConfiguration.maxTextWeight - TLStoryConfiguration.minTextWeight)
            self.blockView.centerY = (self.height - 30) * (1 - ratio)
            self.delegate?.sliderDragging(ratio: self.ratio)
        }
        
        if type == .draw {
            let ratio = (TLStoryConfiguration.defaultDrawLineWeight - TLStoryConfiguration.minDrawLineWeight) / (TLStoryConfiguration.maxDrawLineWeight - TLStoryConfiguration.minDrawLineWeight)
            self.blockView.centerY = (self.height - 30) * (1 - ratio)
            self.delegate?.sliderDragging(ratio: self.ratio)
        }
    }
    
    fileprivate func beginTouchAnim(autoreverses:Bool, isBegin:Bool) {
        let pathAnim = CABasicAnimation.init(keyPath: "path")
        pathAnim.fromValue = isBegin ? path.cgPath : toPath.cgPath
        pathAnim.toValue = isBegin ? toPath.cgPath : path.cgPath
        pathAnim.beginTime = 0
        pathAnim.fillMode = kCAFillModeBoth
        pathAnim.isRemovedOnCompletion = false
        
        let alphaAnim = CABasicAnimation.init(keyPath: "opacity")
        alphaAnim.fromValue = isBegin ? 0.3 : 0.5
        alphaAnim.toValue = isBegin ? 0.5 : 0.3
        alphaAnim.beginTime = 0
        alphaAnim.fillMode = kCAFillModeBoth
        alphaAnim.isRemovedOnCompletion = false
        
        let groupAnim = CAAnimationGroup.init()
        groupAnim.animations = [pathAnim,alphaAnim]
        groupAnim.autoreverses = autoreverses
        groupAnim.duration = 0.3
        groupAnim.fillMode = kCAFillModeBoth
        groupAnim.isRemovedOnCompletion = false
        groupAnim.delegate = self
        
        self.sliderLayer.add(groupAnim, forKey: nil)
    }
    
    @objc fileprivate func panAction(sender:UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        
        if point.y < 15 || point.y > self.height - 15 {
            self.isBeginAnim = false
            self.beginTouchAnim(autoreverses: false, isBegin: false)
            return
        }

        if sender.state == .began {
            self.isBeginAnim = true
            self.beginTouchAnim(autoreverses: false, isBegin: true)
            return
        }
        
        if sender.state == .changed {
            blockView.centerY = point.y
            self.updateRatio(centerY: point.y)
            return
        }
        
        if sender.state == .ended || sender.state == .cancelled {
            self.isBeginAnim = false
            self.beginTouchAnim(autoreverses: false, isBegin: false)
        }
    }
    
    @objc fileprivate func tapAction(sender:UITapGestureRecognizer) {
        let point = sender.location(in: self)
        if point.y < 15 || point.y > self.height - 15 {
            return
        }
        UIView.animate(withDuration: 0.25) { 
            self.blockView.centerY = point.y
        }
        self.beginTouchAnim(autoreverses: true, isBegin: true)
        self.updateRatio(centerY: point.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStorySliderView: CAAnimationDelegate {
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {
            return
        }
        if isBeginAnim {
            self.sliderLayer.path = toPath.cgPath
            self.sliderLayer.opacity = 0.5
        }else {
            self.sliderLayer.path = path.cgPath
            self.sliderLayer.opacity = 0.3
        }
    }
}
