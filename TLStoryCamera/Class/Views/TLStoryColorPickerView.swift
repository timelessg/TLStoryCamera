//
//  TLStoryColorPickerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryColorPickerViewDelegate: NSObjectProtocol {
    func storyColorPickerDidChange(color:UIColor)
    func storyColorPickerDidChange(percent:CGFloat)
}

class TLStoryColorPickerView: UIView {
    public weak var delegate:TLStoryColorPickerViewDelegate?
    
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
    
    fileprivate var sliderView:TLStorySliderView?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sliderBtn.addTarget(self, action: #selector(sliderAction), for: .touchUpInside)
        self.addSubview(sliderBtn)
        sliderBtn.bounds = CGRect.init(x: 0, y: 0, width: 28, height: 28)
        sliderBtn.center = CGPoint.init(x: 20, y: 30)
        
        let collectionViewX = sliderBtn.x + sliderBtn.width + 6
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: (self.width - collectionViewX) / 9, height: 30)
        layout.minimumLineSpacing = 0.01
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: CGRect.init(x: collectionViewX, y: 18, width: self.width - collectionViewX, height: 24), collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.delegate = self
        collectionView!.dataSource = self;
        collectionView!.isPagingEnabled = true
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.register(TLColorPaletteCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.contentSize = CGSize.init(width: self.width - 25, height: 24)
        self.addSubview(collectionView!)
        
        self.addSubview(pageControl)
        pageControl.frame = CGRect.init(x: 0, y: 0, width: self.width, height: 20)
        pageControl.center = CGPoint.init(x: self.width / 2, y: self.height - pageControl.height / 2)
        
        sliderView = TLStorySliderView.init(frame: CGRect.init(x: 0, y: -196, width: 40, height: 200))
        sliderView?.delegate = self
        sliderView?.isHidden = true
        self.addSubview(sliderView!)
    }
    
    public func set(hidden:Bool) {
        if !hidden {
            sliderView?.isHidden = true
        }
        self.isHidden = hidden
    }
    
    public func reset() {
        self.collectionView?.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .left)
    }
    
    public func hiddenSlider() {
        sliderBtn.isSelected = false
        sliderView?.set(hidden: true, anim: true)
    }
    
    @objc fileprivate func sliderAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        sliderView?.set(hidden: !sender.isSelected, anim: true)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.sliderView!.frame.contains(point) {
            return true
        }
        return super.point(inside: point, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension TLStoryColorPickerView: UICollectionViewDelegate, UICollectionViewDataSource {
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
        self.delegate?.storyColorPickerDidChange(color: color)
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.width)
    }
}

extension TLStoryColorPickerView: TLSliderDelegate {
    func sliderDragging(ratio: CGFloat) {
        self.delegate?.storyColorPickerDidChange(percent: ratio)
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
