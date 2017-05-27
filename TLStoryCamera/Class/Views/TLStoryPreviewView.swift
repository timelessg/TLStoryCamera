//
//  TLStoryPreviewView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryPreviewDelegate:NSObjectProtocol {
    func storyPreviewClose()
    func storyPreviewDidPublish(type:TLStoryType, url:URL?)
}

class TLStoryPreviewView: UIView {
    public var editedImg:UIImage?
    
    public lazy var closeBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_icon_close"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var drawBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_drawing_tool"), for: .normal)
        btn.addTarget(self, action: #selector(drawAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var tagsBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_tags"), for: .normal)
        btn.addTarget(self, action: #selector(addTagsAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var textBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_text"), for: .normal)
        btn.addTarget(self, action: #selector(addTextAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var saveBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_download"), for: .normal)
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var publishBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_publish"), for: .normal)
        btn.addTarget(self, action: #selector(publishAction), for: .touchUpInside)
        return btn
    }()
    
    public      var stickerPickerView:TLStickerPickerView?
    
    public      var stageView:TLStickerStageView?
    
    public      var textEditer:TLStoryTextEditerView?
    
    public      var drawView:TLStoryDrawView?
    
    public      var drawToolsBar:TLStoryDrawToolBar?
    
    public      var colorPalette:TLColorPaletteView?
    
    public      var silderView:TLStorySliderView?
    
    public      var swipeUp:UISwipeGestureRecognizer?
    
    public      var tapGesture:UITapGestureRecognizer?
    
    public weak var delegate:TLStoryPreviewDelegate?
    
    fileprivate var isDrawing = false
    
    fileprivate var isTextInput = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawView = TLStoryDrawView.init(frame: self.bounds)
        drawView?.delegate = self
        self.addSubview(drawView!)
        
        stageView = TLStickerStageView.init(frame: self.bounds)
        stageView!.delegate = self
        self.addSubview(stageView!)
        
        textEditer = TLStoryTextEditerView.init(frame: self.bounds)
        textEditer!.delegate = self
        self.addSubview(textEditer!)
        
        stickerPickerView = TLStickerPickerView.init(frame: CGRect.init(x: 0, y: self.height, width: self.width, height: self.height))
        stickerPickerView?.delegate = self
        self.addSubview(stickerPickerView!)
        
        addSubview(closeBtn)
        closeBtn.sizeToFit()
        closeBtn.origin = CGPoint.init(x: 15, y: 15)
        
        addSubview(drawBtn)
        drawBtn.sizeToFit()
        drawBtn.origin = CGPoint.init(x: self.width - 15 - drawBtn.width, y: 15)
        
        addSubview(textBtn)
        textBtn.sizeToFit()
        textBtn.center = CGPoint.init(x: drawBtn.centerX - 45, y: drawBtn.centerY)
        
        addSubview(tagsBtn)
        tagsBtn.sizeToFit()
        tagsBtn.center = CGPoint.init(x: textBtn.centerX - 45, y: closeBtn.centerY)
        
        addSubview(saveBtn)
        saveBtn.sizeToFit()
        saveBtn.origin = CGPoint.init(x: 15, y: self.height - 15 - saveBtn.height)
        
        addSubview(publishBtn)
        publishBtn.sizeToFit()
        publishBtn.origin = CGPoint.init(x: self.width - publishBtn.width - 15, y: self.height - publishBtn.height - 15)
        
        colorPalette = TLColorPaletteView.init(frame: CGRect.init(x: 0, y: self.height - 60, width: self.width, height: 60))
        colorPalette!.delegate = self
        colorPalette!.isHidden = true
        self.addSubview(colorPalette!)
        
        silderView = TLStorySliderView.init(frame: CGRect.init(x: 0, y: self.height - 250, width: 40, height: 195))
        silderView!.delegate = self
        silderView!.isHidden = true
        self.addSubview(silderView!)
        
        drawToolsBar = TLStoryDrawToolBar.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: 55))
        drawToolsBar!.delegate = self
        drawToolsBar!.isHidden = true
        self.addSubview(drawToolsBar!)
        
        swipeUp = UISwipeGestureRecognizer.init(target: self, action: #selector(addTagsAction))
        swipeUp?.direction = .up
        self.addGestureRecognizer(swipeUp!)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(addTextAction))
        self.addGestureRecognizer(tapGesture!)
    }
    
    public func closeAction() {
        delegate?.storyPreviewClose()
        self.removeFromSuperview()
    }
    
    public func drawAction() {
        isDrawing = true
        stageView!.isUserInteractionEnabled = false
        self.colorPalette!.setDefault(color: nil)
        self.colorPalette!.isHidden = false
        self.drawToolsBar!.isHidden = false
        self.silderView!.isHidden = true
        self.silderView!.setDefaultValue(type: .draw)
        self.hideAllIcons()
        self.allGesture(enable: false)
    }
    
    public func addTagsAction() {
        stageView!.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.25, animations: {
            self.stickerPickerView?.y = self.height - 380
        }) { (x) in
            self.hideAllIcons()
            self.allGesture(enable: false)
        }
    }
    
    public func addTextAction() {
        isDrawing = false
        stageView!.isUserInteractionEnabled = true
        self.colorPalette!.setDefault(color: nil)
        self.textEditer?.show(sticker: nil)
    }
    
    public func saveAction() {
        
    }
    
    public func publishAction() {
        
    }
    
    public func hideAllIcons() {
        
    }
    
    public func showAllIcons() {
        
    }
    
    public func allGesture(enable:Bool) {
        if enable {
            self.addGestureRecognizer(swipeUp!)
            self.addGestureRecognizer(tapGesture!)
        }else {
            self.removeGestureRecognizer(swipeUp!)
            self.removeGestureRecognizer(tapGesture!)
        }
    }
    
    public func getEditImg() -> UIImage? {
        let drawImg = self.drawView!.screenshot()
        let stickerImg = self.stageView!.screenshot()
        return drawImg.imageMontage(img: stickerImg)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let v = super.hitTest(point, with: event) else {
            return nil
        }
        
        if v.isKind(of: TLStoryDrawView.self) || v.isKind(of: TLStickerStageView.self) {
            if isDrawing {
                return self.drawView
            }else {
                return self.stageView
            }
        }else {
            return v
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryPreviewView:TLStickerPickerViewDelegate {
    internal func stickerPickerDidSelectedStickers(img: UIImage) {
        stageView?.addSticker(img: img)
        self.isDrawing = false
        stageView?.isUserInteractionEnabled = true
    }
    internal func stickerPickerHidden(view:TLStickerPickerView) {
        self.showAllIcons()
        self.allGesture(enable: true)
    }
}

extension TLStoryPreviewView: TLStickerStageViewDelegate {
    internal func stickerStageStickerDragging(_ dragging: Bool) {
        if dragging {
            self.hideAllIcons()
        }else {
            self.showAllIcons()
        }
    }
    
    internal func stickerStageTextEditing(textSticker: TLStickerTextView) {
        textSticker.isHidden = true
        self.colorPalette!.setDefault(color: textSticker.textColor)
        self.textEditer?.show(sticker: textSticker)
        self.hideAllIcons()
    }
}

extension TLStoryPreviewView: TLStoryDrawViewDelegate {
    internal func drawView(drawing: Bool) {
        self.hideAllIcons()
        self.colorPalette!.isHidden = drawing
        self.drawToolsBar!.isHidden = drawing
        if !self.silderView!.isHidden {
            self.silderView!.isHidden = true
        }
    }
}

extension TLStoryPreviewView: TLStoryDrawToolBarDelegate {
    internal func undo() {
        self.drawView?.undo()
    }
    internal func confrim() {
        isDrawing = false
        stageView?.isUserInteractionEnabled = true
        self.colorPalette!.isHidden = true
        self.drawToolsBar!.isHidden = true
        self.silderView!.isHidden = true
        self.showAllIcons()
        self.allGesture(enable: true)
    }
}

extension TLStoryPreviewView: TLSliderDelegate {
    internal func sliderDragging(ratio: CGFloat) {
        if isDrawing {
            let lineWidth = (TLStoryConfiguration.maxDrawLineWeight - TLStoryConfiguration.minDrawLineWeight) * ratio + TLStoryConfiguration.minDrawLineWeight
            self.drawView?.lineWidth = lineWidth
        }
        
        if isTextInput {
            let size = (TLStoryConfiguration.maxTextWeight - TLStoryConfiguration.minTextWeight) * ratio + TLStoryConfiguration.minTextWeight
            textEditer!.setTextSize(size: size)
        }
    }
}

extension TLStoryPreviewView: TLColorPaletteViewDelegate {
    internal func colorPaletteDidSelected(color: UIColor) {
        if isDrawing {
            drawView?.lineColor = color
        }
        
        if isTextInput {
            textEditer!.setTextColor(color: color)
        }
    }
    
    internal func colorPaletteSliderView(hidden: Bool) {
        if hidden {
            UIView.animate(withDuration: 0.25, animations: {
                self.silderView!.y = self.colorPalette!.y - 195 + 20
                self.silderView!.alpha = 0
            }, completion: { (x) in
                self.silderView!.isHidden = true
            })
        }else {
            self.silderView!.isHidden = false
            silderView!.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.silderView!.y = self.colorPalette!.y - 195
                self.silderView!.alpha = 1
            })
        }
    }
}

extension TLStoryPreviewView: TLStoryTextEditerDelegate {
    internal func textEditerKeyboard(hidden: Bool, offsetY: CGFloat) {
        self.colorPalette!.isHidden = hidden
        self.isTextInput = !hidden
        self.silderView!.isHidden = true
        
        if hidden {
            self.silderView!.isHidden = true
            UIView.animate(withDuration: 0.25) {
                self.colorPalette!.y = self.height - 60
                self.silderView!.y = self.colorPalette!.y - 195 + 20
            }
            self.allGesture(enable: true)
            self.drawToolsBar!.isHidden = true
            self.showAllIcons()
        }else {
            UIView.animate(withDuration: 0.25) {
                self.colorPalette?.y = self.height - 60 - offsetY
                self.silderView!.y = self.colorPalette!.y - 195
            }
            self.allGesture(enable: false)
            self.silderView!.setDefaultValue(type: .text)
            self.hideAllIcons()
        }
    }
    
    internal func textEditerDidCompleteEdited(sticker: TLStickerTextView, isNew: Bool) {
        if isNew {
            self.stageView?.addTextView(sticker: sticker)
        }else {
            sticker.isHidden = false
        }
    }
}
