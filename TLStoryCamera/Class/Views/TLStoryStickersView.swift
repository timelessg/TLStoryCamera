//
//  TLStoryStickersView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryStickersViewDelegate: NSObjectProtocol {
    func storyStickers(editing:Bool)
    func storyTextStickersBeEditing(sticker:TLStoryTextSticker)
}

class TLStoryStickersView: UIView {
    public weak var delegate:TLStoryStickersViewDelegate?
    
    fileprivate var deleteIco = UIImageView.init(image: #imageLiteral(resourceName: "story_publish_icon_delete"))
    
    fileprivate var stickers = [UIView]()
    
    fileprivate var isPrepareDelete:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(deleteIco)
        deleteIco.contentMode = .center
        deleteIco.isHidden = true
        deleteIco.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        deleteIco.center = CGPoint.init(x: self.width / 2, y: self.height - 35)
    }
    
    public func addSub(textSticker:TLStoryTextSticker) {
        textSticker.delegate = self
        textSticker.textView.isUserInteractionEnabled = false
        self.addSubview(textSticker)
        self.stickers.append(textSticker)
    }
    
    public func addSub(image:UIImage) {
        let imgSticker = TLStoryImageSticker.init(img: image)
        imgSticker.delegate = self
        imgSticker.center = CGPoint.init(x: self.width / 2, y: self.height / 2)
        self.addSubview(imgSticker)
        self.stickers.append(imgSticker)
    }
    
    fileprivate func removeSub(textSticker:UIView) {
        textSticker.removeFromSuperview()
        if let index = stickers.index(of: textSticker) {
            stickers.remove(at: index)
        }
    }
    
    fileprivate func deleteIcon(zoomIn:Bool) {
        if zoomIn {
            UIView.animate(withDuration: 0.25) {
                self.deleteIco.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            }
        }else {
            UIView.animate(withDuration: 0.25) {
                self.deleteIco.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
    }
    
    public func reset() {
        for sticker in stickers {
            sticker.removeFromSuperview()
        }
        stickers.removeAll()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryStickersView: TLStoryStickerDelegate {
    internal func stickerView(handing: Bool) {
        self.delegate?.storyStickers(editing: handing)
    }
    
    internal func stickerViewDraggingDelete(point: CGPoint, sticker: UIView, isEnd: Bool) {
        let cPoint = self.convert(point, to: deleteIco)
        if self.deleteIco.point(inside: cPoint, with: nil) {
            if !isPrepareDelete {
                (sticker as! TLStoryStickerProtocol).zoom(out: true)
                isPrepareDelete = true
                self.deleteIcon(zoomIn: true)
            }
        }else {
            if isPrepareDelete {
                (sticker as! TLStoryStickerProtocol).zoom(out: false)
                isPrepareDelete = false
                self.deleteIcon(zoomIn: false)
            }
        }
        
        if isPrepareDelete && isEnd {
            UIView.animate(withDuration: 0.26, animations: {
                sticker.bounds = CGRect.init(x: 0, y: 0, width: 0, height: 0)
                sticker.alpha = 0
            }, completion: { (x) in
                self.removeSub(textSticker: sticker)
                self.isPrepareDelete = false
            })
            self.deleteIcon(zoomIn: false)
        }
        
        self.deleteIco.isHidden = isEnd
    }
    
    internal func stickerViewBecomeFirstRespond(sticker: UIView) {
        for v in stickers {
            if v == sticker {
                self.bringSubview(toFront: v)
                break;
            }
        }
    }
}

extension TLStoryStickersView: TLStoryTextStickerDelegate {
    internal func storyTextStickerEditing(sticker: TLStoryTextSticker) {
        self.delegate?.storyTextStickersBeEditing(sticker: sticker)
    }
}
