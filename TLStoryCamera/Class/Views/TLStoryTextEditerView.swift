//
//  TLStoryTextEditerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryTextEditerDelegate: NSObjectProtocol {
    func textEditerDidCompleteEdited(sticker:TLStickerTextView, isNew:Bool)
    func textEditerKeyboard(hidden:Bool, offsetY: CGFloat)
}

class TLStoryTextEditerView: UIView {
    fileprivate var inputTextView:UITextView = {
        let textView = UITextView.init()
        textView.backgroundColor = UIColor.clear
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.font = UIFont.boldSystemFont(ofSize: TLStoryConfiguration.defaultTextWeight)
        return textView
    }()
    
    fileprivate var editingSticker: TLStickerTextView?
    
    public weak var delegate:TLStoryTextEditerDelegate?
    
    fileprivate var textToolsBar:TLStoryTextInputToolsBar?
    
    fileprivate var tap:UITapGestureRecognizer?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(colorHex: 0x000000, alpha: 0.5)
        self.isHidden = true
        
        inputTextView.delegate = self
        
        textToolsBar = TLStoryTextInputToolsBar.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: 55))
        textToolsBar!.delegate = self
        self.addSubview(textToolsBar!)
        
        self.addSubview(inputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(sticker:TLStickerTextView?) {
        self.isHidden = false
        
        if let s = sticker {
            editingSticker = s
            inputTextView.text = s.text
            inputTextView.font = s.font
            inputTextView.textColor = s.textColor
            inputTextView.textAlignment = s.textAlignment
            let size = inputTextView.sizeThatFits(CGSize.init(width: inputTextView.width, height: CGFloat(MAXFLOAT)))
            inputTextView.bounds = CGRect.init(x: 0, y: 0, width: inputTextView.width, height: size.height)
        }else {
            inputTextView.bounds = CGRect.init(x: 0, y: 0, width: self.width - 20, height: TLStoryConfiguration.defaultTextWeight + 20)
            inputTextView.text = ""
            inputTextView.font = UIFont.boldSystemFont(ofSize: TLStoryConfiguration.defaultTextWeight)
            inputTextView.textAlignment = .center
            inputTextView.textColor = UIColor.white
        }
        
        tap = UITapGestureRecognizer.init(target: self, action: #selector(competeEdit))
        self.addGestureRecognizer(tap!)
        
        inputTextView.becomeFirstResponder()
    }
    
    @objc fileprivate func keyboardWillShow(sender:NSNotification) {
        guard let frame = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        
        if editingSticker != nil {
            let toPoint = CGPoint.init(x: self.width / 2, y: (self.height - frame.height) / 2)
            self.inputTextView.center = toPoint
            self.showAnim(to: toPoint)
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.inputTextView.center = CGPoint.init(x: self.width / 2, y: (self.height - frame.height) / 2)
            })
        }
        
        self.delegate?.textEditerKeyboard(hidden: false, offsetY: frame.height)
    }
    
    @objc fileprivate func keyboardWillHide() {
        if editingSticker != nil {
            self.hideAnim()
        }else {
            self.isHidden = true
        }
        
        self.delegate?.textEditerKeyboard(hidden: true, offsetY: 0)
    }
    
    @objc fileprivate func competeEdit() {
        if let s = editingSticker {
            if isEmpty(str: inputTextView.text) {
                s.removeFromSuperview()
                reset()
                return
            }
            s.font = inputTextView.font
            s.text = inputTextView.text
            s.textColor = inputTextView.textColor
            s.textAlignment = inputTextView.textAlignment
        }else {
            if isEmpty(str: inputTextView.text) {
                reset()
                return
            }
            let sticker = TLStickerTextView.init(frame: self.inputTextView.bounds)
            sticker.center = inputTextView.center
            sticker.font = inputTextView.font
            sticker.text = inputTextView.text
            sticker.textColor = inputTextView.textColor
            sticker.textAlignment = inputTextView.textAlignment
            self.delegate?.textEditerDidCompleteEdited(sticker: sticker, isNew: true)
        }
        
        reset()
    }
    
    fileprivate func reset() {
        self.inputTextView.resignFirstResponder()
        
        if let t = tap {
            self.removeGestureRecognizer(t)
        }
    }
    
    fileprivate func showAnim(to point:CGPoint) {
        let radians = atan2f(Float(self.editingSticker!.transform.b), Float(self.editingSticker!.transform.a))
        
        let positionAnim = CABasicAnimation.init(keyPath: "position")
        positionAnim.fromValue = editingSticker!.center
        positionAnim.toValue = point
        
        let rotationAnim = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = radians
        rotationAnim.toValue = 0
        
        let groupAnim = CAAnimationGroup.init()
        groupAnim.animations = [positionAnim,rotationAnim]
        groupAnim.duration = 0.25
        groupAnim.isRemovedOnCompletion = true
        
        self.inputTextView.layer.add(groupAnim, forKey: "beginAnim")
    }
    
    fileprivate func hideAnim() {
        let radians = atan2f(Float(self.editingSticker!.transform.b), Float(self.editingSticker!.transform.a))
        
        let positionAnim = CABasicAnimation.init(keyPath: "position")
        positionAnim.fromValue = self.inputTextView.center
        positionAnim.toValue = self.editingSticker!.center
        
        let rotationAnim = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = 0
        rotationAnim.toValue = radians
        
        let groupAnim = CAAnimationGroup.init()
        groupAnim.animations = [positionAnim,rotationAnim]
        groupAnim.duration = 0.25
        groupAnim.fillMode = kCAFillModeForwards
        groupAnim.isRemovedOnCompletion = false
        groupAnim.delegate = self
        
        self.inputTextView.layer.add(groupAnim, forKey: "endAnim")
    }
    
    public func setTextColor(color:UIColor) {
        self.inputTextView.textColor = color
    }
    
    public func setTextSize(size:CGFloat) {
        self.inputTextView.font = UIFont.boldSystemFont(ofSize: size)
        self.inputTextView.height = size + 20
    }
    
    public func setTextAlignment() -> NSTextAlignment {
        let r = inputTextView.textAlignment.rawValue + 1
        let textAlignment = NSTextAlignment(rawValue: r > 2 ? 0 : r)!
        inputTextView.textAlignment = textAlignment
        return textAlignment
    }
    
    fileprivate func isEmpty(str:String) -> Bool {
        let set = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return set.characters.count == 0 || str.characters.count == 0
    }
}

extension TLStoryTextEditerView: CAAnimationDelegate {
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.inputTextView.center = self.editingSticker!.center
        self.inputTextView.layer.removeAllAnimations()
        if let s = editingSticker {
            self.delegate?.textEditerDidCompleteEdited(sticker: s, isNew: false)
        }
        self.editingSticker = nil
        self.isHidden = true
    }
}

extension TLStoryTextEditerView: UITextViewDelegate {
    internal func textViewDidChange(_ textView: UITextView) {
        if (textView.markedTextRange == nil) {
            textView.flashScrollIndicators()
            
            let size = textView.sizeThatFits(CGSize.init(width: inputTextView.width, height: CGFloat(MAXFLOAT)))
            inputTextView.bounds = CGRect.init(x: 0, y: 0, width: inputTextView.width, height: size.height)
        }
    }
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.competeEdit()
            return false
        }
        return true
    }
}

extension TLStoryTextEditerView: TLStoryTextInputToolsBarDelegate {
    internal func textInputToolsBarChange() -> NSTextAlignment {
        return self.setTextAlignment()
    }
    
    internal func textInputToolsBarConfirm() {
        self.competeEdit()
    }
}



protocol TLStoryTextInputToolsBarDelegate:NSObjectProtocol {
    func textInputToolsBarChange() -> NSTextAlignment
    func textInputToolsBarConfirm()
}

class TLStoryTextInputToolsBar: UIView {
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
    
    public weak var delegate:TLStoryTextInputToolsBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(textAlignmentBtn)
        textAlignmentBtn.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        textAlignmentBtn.center = CGPoint.init(x: textAlignmentBtn.width / 2, y: textAlignmentBtn.height / 2)
        
        self.addSubview(confrimBtn)
        confrimBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        confrimBtn.center = CGPoint.init(x: self.width - confrimBtn.width / 2, y:confrimBtn.height / 2)
        
        textAlignmentBtn.addTarget(self, action: #selector(textAlignmentAction), for: .touchUpInside)
        confrimBtn.addTarget(self, action: #selector(confrimAction), for: .touchUpInside)
    }
    
    public func textAlignmentAction(sender:UIButton) {
        let imgs = [NSTextAlignment.left:#imageLiteral(resourceName: "story_publish_icon_align_left"),
                    NSTextAlignment.center:#imageLiteral(resourceName: "story_publish_icon_align_center"),
                    NSTextAlignment.right:#imageLiteral(resourceName: "story_publish_icon_align_right")]
        let textAlignment = self.delegate?.textInputToolsBarChange()
        print(textAlignment!)
        sender.setImage(imgs[textAlignment!], for: .normal)
    }
    
    public func confrimAction() {
        self.delegate?.textInputToolsBarConfirm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
