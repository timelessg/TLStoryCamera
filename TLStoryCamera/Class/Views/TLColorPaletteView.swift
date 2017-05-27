//
//  TLColorPaletteView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

enum TLStoryDeployType {
    case text
    case draw
}

protocol TLColorPaletteViewDelegate: NSObjectProtocol {
    func colorPaletteDidSelected(color:UIColor)
    func colorPaletteSliderView(hidden:Bool)
}

class TLColorPaletteView: UIView {
    fileprivate lazy var pageControl:UIPageControl = {
        let control = UIPageControl.init()
        control.currentPage = 1
        control.numberOfPages = 3
        return control
    }()
    
    fileprivate var sliderBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_drawing_tool_size"), for: .normal)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        return btn
    }()
    
    fileprivate var collectionView:UICollectionView?
    
    fileprivate var colors:[UIColor] = {
        var array = [UIColor]()
        let plist = Bundle.main.path(forResource: "WBStoryTextColor", ofType: "plist")
        if let p = plist, let colors = NSArray.init(contentsOfFile: p) as? [[String:String]] {
            for colorDic in colors {
                if var c = colorDic["background"], let color = UIColor.color(hexString: c) {
                    array.append(color)
                }
            }
        }
        return array
    }()
    
    public weak var delegate:TLColorPaletteViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: (self.width - 40) / 9, height: 30)
        layout.minimumLineSpacing = 0.01
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: CGRect.init(x: 40, y: 15, width: self.width - 40, height: 30), collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.delegate = self
        collectionView!.dataSource = self;
        collectionView!.isPagingEnabled = true
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.register(TLColorPaletteCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.contentSize = CGSize.init(width: self.width - 45, height: 30)
        self.addSubview(collectionView!)
        
        self.addSubview(pageControl)
        pageControl.frame = CGRect.init(x: 0, y: 0, width: 100, height: 20)
        pageControl.center = CGPoint.init(x: self.width / 2, y: self.height - pageControl.height / 2)
        
        sliderBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        sliderBtn.center = CGPoint.init(x: 5 + sliderBtn.width / 2, y: self.height / 2)
        sliderBtn.addTarget(self, action: #selector(sliderAction), for: .touchUpInside)
        self.addSubview(sliderBtn)
    }
    
    public func setDefault(color:UIColor?) {
        if let c = color, let index = colors.index(of: c) {
            collectionView?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .left, animated: false)
            sliderBtn.backgroundColor = c
        }else {
            collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .left, animated: false)
            sliderBtn.backgroundColor = UIColor.white
        }
    }
    
    @objc fileprivate func sliderAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.colorPaletteSliderView(hidden: !sender.isSelected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLColorPaletteView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TLColorPaletteCell
        cell.color = colors[indexPath.row]
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TLColorPaletteCell
        cell.selectedAnim()
        let color = colors[indexPath.row]
        self.sliderBtn.backgroundColor = color
        self.delegate?.colorPaletteDidSelected(color: color)
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.width)
    }
}

class TLColorPaletteCell: UICollectionViewCell {
    fileprivate lazy var colorView = UIView.init()
    public var color:UIColor? {
        get {
            return self.colorView.backgroundColor
        }
        set {
            self.colorView.backgroundColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        colorView.bounds = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        colorView.center = CGPoint.init(x: self.width / 2, y: self.height / 2)
        colorView.layer.cornerRadius = colorView.width / 2
        colorView.layer.masksToBounds = true
        colorView.layer.borderColor = UIColor.white.cgColor
        colorView.layer.borderWidth = 2
        self.contentView.addSubview(colorView)
    }
    
    public func selectedAnim() {
        let zoomAnim = CABasicAnimation.init(keyPath: "transform.scale")
        zoomAnim.fromValue = 1
        zoomAnim.toValue = 1.2
        zoomAnim.duration = 0.1
        zoomAnim.autoreverses = true
        zoomAnim.isRemovedOnCompletion = true
        self.colorView.layer.add(zoomAnim, forKey: nil)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
