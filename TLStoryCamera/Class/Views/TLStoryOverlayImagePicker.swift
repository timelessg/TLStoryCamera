//
//  TLStoryOverlayImagePicker.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryOverlayImagePickerDelegate: NSObjectProtocol {
    func storyOverlayImagePickerDidSelected(img:UIImage) -> Void
    func storyOverlayImagePickerDismiss()
}

class TLStoryOverlayImagePicker: UIView {
    public weak var delegate:TLStoryOverlayImagePickerDelegate?
    
    fileprivate var imagePicker:TLStoryImagePickerView?
    
    fileprivate var tap:UITapGestureRecognizer?
    
    fileprivate var swipeDown:UISwipeGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imagePicker = TLStoryImagePickerView.init(frame: CGRect.init(x: 0, y: self.height, width: self.width, height: self.height), callback: { [weak self] (img) -> (Void) in
            if let i = img {
                self?.delegate?.storyOverlayImagePickerDidSelected(img: i)
            }
            self?.isHidden = true
            self?.delegate?.storyOverlayImagePickerDismiss()
        })
        self.addSubview(imagePicker!)
        
        tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissAction))
        tap!.delegate = self
        self.addGestureRecognizer(tap!)
        
        swipeDown = UISwipeGestureRecognizer.init(target: self, action: #selector(dismissAction))
        swipeDown!.delegate = self
        swipeDown!.direction = .down
        self.addGestureRecognizer(swipeDown!)
    }
    
    @objc fileprivate func dismissAction() {
        self.imagePicker?.dismiss()
    }
    
    public func display() {
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.imagePicker!.y = self.height - 380
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryOverlayImagePicker: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        if self.imagePicker!.frame.contains(point) {
            return false
        }
        return true
    }
}


class TLStoryImagePickerView: UIView {
    fileprivate var blurBgView:UIVisualEffectView?
    
    fileprivate var handleView = UIView.init()
    
    fileprivate var handleBgView = UIView.init()
    
    fileprivate var collectionView:UICollectionView?
    
    fileprivate var stickers:[UIImage] = {
        var array = [UIImage]()
        let plist = Bundle.main.path(forResource: "WBStoryStickers", ofType: "plist")
        if let p = plist, let stickers = NSArray.init(contentsOfFile: p) as? [[String:String]] {
            var i = 1
            for stickerDic in stickers {
                if let named = stickerDic["imageName"], let img = UIImage.imageWithStickers(named: named ) {
                    array.append(img)
                }
            }
        }
        return array
    }()
    
    fileprivate var pincheGesture:UIPanGestureRecognizer?
    
    fileprivate var beginPoint = CGPoint.zero
    
    fileprivate var offsetY:CGFloat = 0
    
    fileprivate var callback:((UIImage?) -> (Void))?
    
    init(frame:CGRect, callback:@escaping ((UIImage?) -> (Void))) {
        super.init(frame: frame)
        self.callback = callback
        
        self.blurBgView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        self.blurBgView!.frame = self.bounds
        self.addSubview(blurBgView!)
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: self.width / 3 - 20, height: self.width / 3)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.delegate = self
        collectionView!.dataSource = self;
        collectionView!.contentInset = UIEdgeInsets.init(top: 20, left: 10, bottom: self.height - 380, right: 10)
        collectionView!.register(TLStickerCell.self, forCellWithReuseIdentifier: "cell")
        blurBgView!.contentView.addSubview(collectionView!)
        
        blurBgView!.contentView.addSubview(handleBgView)
        handleBgView.frame = CGRect.init(x: 0, y: 0, width: self.width, height: 30)
        handleBgView.isUserInteractionEnabled = true
        
        handleBgView.addSubview(handleView)
        handleView.bounds = CGRect.init(x: 0, y: 0, width: 40, height: 4)
        handleView.center = CGPoint.init(x: handleBgView.width / 2, y: handleBgView.height / 2)
        handleView.layer.cornerRadius = 2
        handleView.backgroundColor = UIColor.white
        handleView.isUserInteractionEnabled = true
        
        pincheGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pincheAction))
        handleBgView.addGestureRecognizer(pincheGesture!)
        
        let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize.init(width: 5, height: 5))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd

        let maskView = UIView(frame: self.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.layer.mask = maskLayer
        
        blurBgView?.mask = maskView
    }
    
    @objc fileprivate func pincheAction(sender:UIPanGestureRecognizer) -> Void {
        let point = sender.location(in: self.superview)
        
        if sender.state == .began {
            self.beginPoint = point
            offsetY = self.convert(beginPoint, from: self.superview).y
        }
        if sender.state == .ended || sender.state == .cancelled {
            if point.y - beginPoint.y > 10 {
                dismiss()
                return
            }
            
            if point.y - beginPoint.y < -10 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.y = 0
                }, completion: { (x) in
                    self.collectionView?.contentInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 0, right: 10)
                    self.collectionView?.removeGestureRecognizer(self.pincheGesture!)
                })
                return
            }
        }
        
        if sender.state == .changed {
            if self.y <= 0 {
                return
            }
            self.y = point.y - offsetY
        }
    }
    
    public func dismiss() {
        if self.y == UIScreen.main.bounds.height {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.y = UIScreen.main.bounds.height
        }, completion: { (x) in
            self.collectionView?.contentInset = UIEdgeInsets.init(top: 20, left: 10, bottom: self.height - 380, right: 10)
            self.collectionView?.removeGestureRecognizer(self.pincheGesture!)
            if let c = self.callback {
                c(nil)
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TLStoryImagePickerView: UICollectionViewDelegate, UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TLStickerCell
        cell.imgView.image = stickers[indexPath.row]
        return cell
    }
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TLStickerCell
        
        UIView.animate(withDuration: 0.3, animations: {
            self.y = UIScreen.main.bounds.height
        }, completion: { (x) in
            self.collectionView?.contentInset = UIEdgeInsets.init(top: 20, left: 10, bottom: self.height - 380, right: 10)
            self.collectionView?.removeGestureRecognizer(self.pincheGesture!)
            if let c = self.callback {
                c(cell.imgView.image)
            }
        })
    }
}

extension TLStoryImagePickerView: UIScrollViewDelegate {
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -20 {
            if let gesture = pincheGesture {
                scrollView.removeGestureRecognizer(gesture)
            }
            pincheGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pincheAction))
            scrollView.addGestureRecognizer(pincheGesture!)
        }else {
            if let p = pincheGesture {
                self.collectionView?.removeGestureRecognizer(p)
            }
        }
    }
}



class TLStickerCell: UICollectionViewCell {
    public lazy var imgView:UIImageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imgView)
        imgView.frame = self.bounds
        
        imgView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
