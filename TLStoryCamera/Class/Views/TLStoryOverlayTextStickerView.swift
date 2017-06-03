//
//  TLStoryOverlayTextStickerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryOverlayTextStickerViewDelegate: NSObjectProtocol {
    func textEditerDidCompleteEdited(sticker:TLStoryTextSticker?)
}

class TLStoryOverlayTextStickerView: UIView {
    public weak var delegate:TLStoryOverlayTextStickerViewDelegate?
    
    fileprivate var textAlignmentBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_align_center"), for: .normal)
        return btn
    }()
    
    fileprivate var confrimBtn: TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setTitle("确定", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var colorPicker:TLStoryColorPickerView?
    
    fileprivate var editingSticker:TLStoryTextSticker?
    
    fileprivate var isNew:Bool = false
    
    fileprivate var lastPosition:CGPoint?
    
    fileprivate var lastTransform:CGAffineTransform?
    
    fileprivate var tap:UITapGestureRecognizer?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(colorHex: 0x000000, alpha: 0.5)
        self.isHidden = true
        
        colorPicker = TLStoryColorPickerView.init(frame: CGRect.init(x: 0, y: self.height, width: self.width, height: 60))
        colorPicker?.delegate = self
        self.addSubview(colorPicker!)
        
        textAlignmentBtn.addTarget(self, action: #selector(textAlignmentAction), for: .touchUpInside)
        self.addSubview(textAlignmentBtn)
        textAlignmentBtn.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        textAlignmentBtn.center = CGPoint.init(x: textAlignmentBtn.width / 2, y: textAlignmentBtn.height / 2)
        
        confrimBtn.addTarget(self, action: #selector(confrimAction), for: .touchUpInside)
        self.addSubview(confrimBtn)
        confrimBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        confrimBtn.center = CGPoint.init(x: self.width - confrimBtn.width / 2, y:confrimBtn.height / 2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(sticker:TLStoryTextSticker?) {
        self.isHidden = false
        
        if let s = sticker {
            editingSticker = s
            self.lastPosition = s.center
            self.lastTransform = s.transform
            isNew = false
        }else {
            editingSticker = TLStoryTextSticker.init(frame: CGRect.init(x: 0, y: 0, width: self.width - 20, height: TLStoryConfiguration.defaultTextWeight + 20))
            editingSticker!.centerX = self.width / 2
            isNew = true
        }
        
        self.addSubview(editingSticker!)
        editingSticker?.textView.delegate = self
        editingSticker?.isUserInteractionEnabled = false
        
        editingSticker?.textView.becomeFirstResponder()
        
        tap = UITapGestureRecognizer.init(target: self, action: #selector(competeEdit))
        tap!.delegate = self
        self.addGestureRecognizer(tap!)
    }
    
    public func reset() {
        textAlignmentBtn.setImage(#imageLiteral(resourceName: "story_publish_icon_align_center"), for: .normal)
        self.colorPicker?.reset()
    }
    
    public func confrimAction() {
        self.competeEdit()
    }
    
    fileprivate func setText(color:UIColor) {
        self.editingSticker?.textView.textColor = color
    }
    
    fileprivate func setText(size:CGFloat) {
        self.editingSticker?.textView.font = UIFont.boldSystemFont(ofSize: size)
        self.editingSticker?.height = size + 20
    }
    
    fileprivate func setTextAlignment() -> NSTextAlignment {
        let r = editingSticker!.textView.textAlignment.rawValue + 1
        let textAlignment = NSTextAlignment(rawValue: r > 2 ? 0 : r)!
        editingSticker?.textView.textAlignment = textAlignment
        return textAlignment
    }
    
    @objc fileprivate func keyboardWillShow(sender:NSNotification) {
        guard let frame = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        let toPoint = CGPoint.init(x: self.width / 2, y: (self.height - frame.height) / 2)
        
        let colorPickerCenter = CGPoint.init(x: self.width / 2, y: self.height - frame.height - colorPicker!.height / 2)
        self.colorPicker?.center = colorPickerCenter
        
        if isNew {
            self.lastPosition = toPoint
            self.lastTransform = self.editingSticker!.transform
            UIView.animate(withDuration: 0.25, animations: {
                self.editingSticker?.center = toPoint
            })
        } else {
            UIView.animate(withDuration: 0.25) {
                self.editingSticker?.center = toPoint
                self.editingSticker?.transform = CGAffineTransform.init(rotationAngle: 0)
            }
        }
        
        self.colorPicker?.set(hidden: false)
    }
    
    @objc fileprivate func keyboardWillHide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.editingSticker?.center = self.lastPosition!
            self.editingSticker?.transform = self.lastTransform!
        }) { (x) in
            if x {
                self.editingSticker?.removeFromSuperview()
                self.editingSticker?.isUserInteractionEnabled = true
                if !self.isEmpty(str: self.editingSticker!.textView.text) {
                    self.delegate?.textEditerDidCompleteEdited(sticker: self.editingSticker!)
                }else {
                    self.delegate?.textEditerDidCompleteEdited(sticker: nil)
                }
                self.editingSticker = nil
                self.isHidden = true
            }
        }
        self.colorPicker?.set(hidden: true)
    }
    
    @objc fileprivate func textAlignmentAction(sender:UIButton) {
        let imgs = [NSTextAlignment.left:#imageLiteral(resourceName: "story_publish_icon_align_left"),
                    NSTextAlignment.center:#imageLiteral(resourceName: "story_publish_icon_align_center"),
                    NSTextAlignment.right:#imageLiteral(resourceName: "story_publish_icon_align_right")]
        let textAlignment = self.setTextAlignment()
        sender.setImage(imgs[textAlignment], for: .normal)
    }
    
    @objc fileprivate func competeEdit() {
        self.editingSticker!.textView.resignFirstResponder()
        if let t = tap {
            self.removeGestureRecognizer(t)
        }
    }
    
    fileprivate func isEmpty(str:String) -> Bool {
        let set = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return set.characters.count == 0 || str.characters.count == 0
    }
}

extension TLStoryOverlayTextStickerView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        
        if self.colorPicker!.frame.contains(point) || self.textAlignmentBtn.frame.contains(point) || self.confrimBtn.frame.contains(point) || self.editingSticker!.frame.contains(point) {
            return false
        }
        return true
    }
}

extension TLStoryOverlayTextStickerView: UITextViewDelegate {
    internal func textViewDidChange(_ textView: UITextView) {
        if (textView.markedTextRange == nil) {
            textView.flashScrollIndicators()
            
            let size = textView.sizeThatFits(CGSize.init(width: editingSticker!.textView.width, height: CGFloat(MAXFLOAT)))
            editingSticker?.bounds = CGRect.init(x: 0, y: 0, width: editingSticker!.width, height: size.height)
        }
    }
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.colorPicker?.hiddenSlider()
        }
        return true
    }
}

extension TLStoryOverlayTextStickerView: TLStoryColorPickerViewDelegate {
    internal func storyColorPickerDidChange(percent: CGFloat) {
        let size = (TLStoryConfiguration.maxTextWeight - TLStoryConfiguration.minTextWeight) * percent + TLStoryConfiguration.minTextWeight
        self.setText(size: size)
    }

    internal func storyColorPickerDidChange(color: UIColor) {
        self.setText(color: color)
    }
}
