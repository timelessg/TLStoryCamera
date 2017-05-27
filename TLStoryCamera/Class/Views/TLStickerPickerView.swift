//
//  TLStickerPickerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStickerPickerViewDelegate: NSObjectProtocol {
    func stickerPickerDidSelectedStickers(img:UIImage) -> Void
    func stickerPickerHidden(view:TLStickerPickerView) -> Void
}

class TLStickerPickerView: UIVisualEffectView {
    fileprivate var handleView = UIView.init()
    
    fileprivate var handleBgView = UIView.init()
    
    fileprivate var collectionView:UICollectionView?
    
    public weak var delegate:TLStickerPickerViewDelegate?
    
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
    
    init(frame:CGRect) {
        super.init(effect: UIBlurEffect.init(style: .light))
        self.frame = frame
        
        let path = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize.init(width: 10, height: 10))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        
        let maskView = UIView(frame: self.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.layer.mask = maskLayer
        self.mask = maskView
        
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
        self.addSubview(collectionView!)
        
        self.addSubview(handleBgView)
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
            if let delegate = self.delegate {
                delegate.stickerPickerHidden(view: self)
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TLStickerPickerView:UICollectionViewDelegate, UICollectionViewDataSource {
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
            if let delegate = self.delegate {
                delegate.stickerPickerDidSelectedStickers(img: cell.imgView.image!)
                delegate.stickerPickerHidden(view: self)
            }
        })
    }
    
}

extension TLStickerPickerView: UIScrollViewDelegate {
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
