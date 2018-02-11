//
//  TLStoryEditContainerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryEditContainerViewDelegate: NSObjectProtocol{
    func storyEditContainerEndDrawing()
    func storyEditContainerSticker(editing:Bool)
    func storyEditContainerTextStickerBeEditing(sticker:TLStoryTextSticker)
    func storyEditContainerSwipeUp()
    func storyEditContainerTap()
    func storyEditSwpieFilter(direction:UISwipeGestureRecognizerDirection)
}

class TLStoryEditContainerView: UIView {
    public weak var delegate:TLStoryEditContainerViewDelegate?
    
    fileprivate var stickersView:TLStoryStickersView?
    
    fileprivate var doodleView:TLStoryDoodleView?
    
    fileprivate var colorPicker:TLStoryColorPickerView?
    
    fileprivate var confrimBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.setTitle("确定", for: .normal)
        btn.showsTouchWhenHighlighted = true
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var undoBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(UIImage.tl_imageWithNamed(named: "story_publish_icon_drawing_cancel"), for: .normal)
        return btn
    }()
    
    fileprivate var isDrawing:Bool = false
    
    fileprivate var tapGesture:UITapGestureRecognizer?
    
    fileprivate var swipeUpGesture:UISwipeGestureRecognizer?
    
    fileprivate var swipeLeftGesture:UISwipeGestureRecognizer?
    
    fileprivate var swipeRightGesture:UISwipeGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        doodleView = TLStoryDoodleView.init(frame: self.bounds)
        doodleView?.delegate = self
        self.addSubview(doodleView!)
        
        stickersView = TLStoryStickersView.init(frame: self.bounds)
        stickersView?.delegate = self
        self.addSubview(stickersView!)
        
        confrimBtn.addTarget(self, action: #selector(confrimAction), for: .touchUpInside)
        self.addSubview(confrimBtn)
        confrimBtn.isHidden = true
        confrimBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        confrimBtn.center = CGPoint.init(x: self.width - confrimBtn.width / 2, y:confrimBtn.height / 2)
        
        undoBtn.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        self.addSubview(undoBtn)
        undoBtn.isHidden = true
        undoBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        undoBtn.center = CGPoint.init(x: self.undoBtn.width / 2, y: confrimBtn.centerY)
        
        colorPicker = TLStoryColorPickerView.init(frame: CGRect.init(x: 0, y: self.height - 60, width: self.width, height: 60))
        colorPicker?.delegate = self
        colorPicker!.isHidden = true
        self.addSubview(colorPicker!)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        tapGesture?.delegate = self
        self.addGestureRecognizer(tapGesture!)
        
        swipeUpGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeUpAction))
        swipeUpGesture?.direction = .up
        swipeUpGesture?.delegate = self
        self.addGestureRecognizer(swipeUpGesture!)
        
        swipeLeftGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(switchFilter));
        swipeLeftGesture!.direction = .left
        swipeLeftGesture?.delegate = self
        self.addGestureRecognizer(swipeLeftGesture!)
        
        swipeRightGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(switchFilter));
        swipeRightGesture!.direction = .right
        swipeRightGesture?.delegate = self
        self.addGestureRecognizer(swipeRightGesture!)
    }
    
    @objc fileprivate func tapAction() {
        self.delegate?.storyEditContainerTap()
    }
    
    @objc fileprivate func swipeUpAction() {
        self.delegate?.storyEditContainerSwipeUp()
    }
    
    @objc fileprivate func switchFilter(sender:UISwipeGestureRecognizer) {
        self.delegate?.storyEditSwpieFilter(direction: sender.direction)
    }
    
    @objc fileprivate func undoAction() {
        doodleView?.undo()
    }
    
    @objc fileprivate func confrimAction() {
        self.doodleIcons(true)
        isDrawing = false
        self.delegate?.storyEditContainerEndDrawing()
        self.doodleView?.isUserInteractionEnabled = false
        stickersView!.isUserInteractionEnabled = true
    }
    
    fileprivate func doodleIcons(_ hidden:Bool) {
        if hidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.confrimBtn.alpha = 0
                self.undoBtn.alpha = 0
                self.colorPicker?.alpha = 0
            }, completion: { (x) in
                if x {
                    self.confrimBtn.isHidden = true
                    self.undoBtn.isHidden = true
                    self.colorPicker?.isHidden = true
                }
            })
        }else {
            self.confrimBtn.isHidden = false
            self.undoBtn.isHidden = false
            self.colorPicker?.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.confrimBtn.alpha = 1
                self.undoBtn.alpha = 1
                self.colorPicker?.alpha = 1
            })
        }
    }
    
    public func add(textSticker:TLStoryTextSticker) {
        self.stickersView?.addSub(textSticker: textSticker)
    }
    
    public func add(img:UIImage) {
        self.stickersView?.addSub(image: img)
    }
    
    public func getScreenshot() -> UIImage {
        let doodleImg = self.doodleView!.screenshot()
        let stickersImg = self.stickersView!.screenshot()
        return doodleImg.imageMontage(img: stickersImg,bgColor: nil, size: UIScreen.main.bounds.size)
    }
    
    public func benginDrawing() {
        self.doodleIcons(false)
        isDrawing = true
        stickersView!.isUserInteractionEnabled = false
        self.doodleView?.isUserInteractionEnabled = true
    }
    
    public func reset() {
        self.doodleView?.erase()
        self.stickersView?.reset()
        self.colorPicker?.reset()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let v = super.hitTest(point, with: event) else {
            return nil
        }
        
        if v.isKind(of: TLStoryDoodleView.self) || v.isKind(of: TLStoryStickersView.self) {
            if isDrawing {
                return self.doodleView
            }else {
                return self.stickersView
            }
        }else {
            return v
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryEditContainerView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isDrawing {
            return false
        }
        return true
    }
}


extension TLStoryEditContainerView: TLStoryStickersViewDelegate {
    internal func storyTextStickersBeEditing(sticker: TLStoryTextSticker) {
        self.delegate?.storyEditContainerTextStickerBeEditing(sticker: sticker)
    }
    
    internal func storyStickers(editing: Bool) {
        self.delegate?.storyEditContainerSticker(editing: editing)
    }
}

extension TLStoryEditContainerView: TLStoryDoodleViewDelegate {
    internal func storyDoodleView(drawing:Bool) {
        self.doodleIcons(drawing)
    }
}

extension TLStoryEditContainerView: TLStoryColorPickerViewDelegate {
    func storyColorPickerDidChange(color: TLStoryColor) {
        doodleView?.lineColor = color.backgroundColor
    }

    internal func storyColorPickerDidChange(percent: CGFloat) {
        let lineWidth = (TLStoryConfiguration.maxDrawLineWeight - TLStoryConfiguration.minDrawLineWeight) * percent + TLStoryConfiguration.minDrawLineWeight
        doodleView?.lineWidth = lineWidth
    }
}
