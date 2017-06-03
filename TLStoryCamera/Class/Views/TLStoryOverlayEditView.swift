//
//  TLStoryOverlayEditView.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/31.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

protocol TLStoryOverlayEditViewDelegate: NSObjectProtocol {
    func storyOverlayEditClose()
    func storyOverlayEditDoodleEditable()
    func storyOverlayEditStickerPickerDisplay()
    func storyOverlayEditTextEditerDisplay()
    func storyOverlayEditAudio(enable:Bool)
    func storyOverlayEditSave()
    func storyOverlayEditPublish()
}

extension TLStoryOverlayEditViewDelegate {
    func storyOverlayEditAudioEnable() {
        
    }
}

class TLStoryOverlayEditView: UIView {
    public weak var delegate:TLStoryOverlayEditViewDelegate?
    
    fileprivate lazy var closeBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_icon_close"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var doodleBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_drawing_tool"), for: .normal)
        btn.addTarget(self, action: #selector(doodleAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var tagsBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_tags"), for: .normal)
        btn.addTarget(self, action: #selector(addTagsAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var textBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_text"), for: .normal)
        btn.addTarget(self, action: #selector(addTextAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var audioEnableBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_voice_on"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_voice_off"), for: .selected)
        btn.addTarget(self, action: #selector(audioEnableAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var saveBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_download"), for: .normal)
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
        
    fileprivate lazy var publishBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_publish"), for: .normal)
        btn.addTarget(self, action: #selector(publishAction), for: .touchUpInside)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(closeBtn)
        closeBtn.bounds = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        closeBtn.origin = CGPoint.init(x: 0, y: 0)
        
        addSubview(doodleBtn)
        doodleBtn.bounds = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        doodleBtn.origin = CGPoint.init(x: self.width - doodleBtn.width, y: 0)
        
        addSubview(textBtn)
        textBtn.bounds = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        textBtn.center = CGPoint.init(x: doodleBtn.centerX - 45, y: doodleBtn.centerY)
        
        addSubview(tagsBtn)
        tagsBtn.bounds = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        tagsBtn.center = CGPoint.init(x: textBtn.centerX - 45, y: closeBtn.centerY)
        
        addSubview(audioEnableBtn)
        audioEnableBtn.bounds = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        audioEnableBtn.center = CGPoint.init(x: tagsBtn.centerX - 45, y: closeBtn.centerY)
        
        addSubview(saveBtn)
        saveBtn.bounds = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        saveBtn.origin = CGPoint.init(x: 0, y: self.height - saveBtn.height)
        
        addSubview(publishBtn)
        publishBtn.sizeToFit()
        publishBtn.origin = CGPoint.init(x: self.width - publishBtn.width - 15, y: self.height - publishBtn.height - 15)
    }
    
    @objc fileprivate func closeAction() {
        self.dismiss()
        self.delegate?.storyOverlayEditClose()
    }
    
    @objc fileprivate func doodleAction() {
        self.dismiss()
        self.delegate?.storyOverlayEditDoodleEditable()
    }
    
    @objc fileprivate func addTagsAction() {
        self.dismiss()
        self.delegate?.storyOverlayEditStickerPickerDisplay()
    }
    
    @objc fileprivate func addTextAction() {
        self.dismiss()
        self.delegate?.storyOverlayEditTextEditerDisplay()
    }
    
    @objc fileprivate func audioEnableAction(sender:TLButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.storyOverlayEditAudio(enable: !sender.isSelected)
    }
    
    @objc fileprivate func saveAction() {
        self.delegate?.storyOverlayEditSave()
    }
    
    @objc fileprivate func publishAction() {
        self.delegate?.storyOverlayEditPublish()
    }
    
    public func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (x) in
            if x {
                self.isHidden = true
            }
        }
    }
    
    public func dispaly() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.closeBtn.frame.contains(point) || self.audioEnableBtn.frame.contains(point) || self.tagsBtn.frame.contains(point) || self.textBtn.frame.contains(point) || self.doodleBtn.frame.contains(point) || self.saveBtn.frame.contains(point) || self.publishBtn.frame.contains(point) {
            return true
        }
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
