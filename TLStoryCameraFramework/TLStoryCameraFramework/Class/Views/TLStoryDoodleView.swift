//
//  TLStoryDoodleView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/31.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryDoodleViewDelegate: NSObjectProtocol{
    func storyDoodleView(drawing:Bool)
}

class TLStoryDoodleBezierPath: UIBezierPath {
    private static let maxPointCount:Int = 5
    
    private var points = [CGPoint](repeating: CGPoint.zero, count: 5)
    private var pointCount : Int = 0
    
    private var startPoint : CGPoint = CGPoint.zero
    
    private var isBengin = false
    
    fileprivate func burshBegin(at point:CGPoint) {
        self.move(to: point)
        startPoint = point
        points[0] = point
        pointCount = 1
    }
    fileprivate func appendPoint(point:CGPoint) -> Bool {
        points[pointCount] = point
        pointCount += 1
        if pointCount == TLStoryDoodleBezierPath.maxPointCount {
            
            isBengin = true
            
            points[3] = CGPoint.init(x: (points[2].x + points[4].x) / 2, y: (points[2].y + points[4].y) / 2)
            
            self.move(to: points[0])
            self.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            
            points[0] = points[3]
            points[1] = points[4]
            pointCount = 2
            
            return true
        }
        return false
    }
    
    fileprivate func end() {
        switch pointCount {
        case 1:
            if !self.isBengin {
                self.addArc(withCenter: self.startPoint, radius: self.lineWidth / 2, startAngle: 0, endAngle: CGFloat(Float.pi * 2.0), clockwise: false)
            }
            break
        case 2:
            self.addLine(to: points[1])
            break
        case 3:
            self.addQuadCurve(to: points[2], controlPoint: points[1])
            break
        case 4:
            self.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            break
        default:
            break
            
        }
    }
}

class TLStoryDoodleLayer: CAShapeLayer {
    private var currentPath = TLStoryDoodleBezierPath.init()
    
    override init() {
        super.init()
        
        self.lineCap = kCALineCapRound
        self.lineJoin = kCALineJoinRound
        self.fillColor = UIColor.clear.cgColor
    }
    
    fileprivate func begin(at point:CGPoint) {
        currentPath.burshBegin(at: point)
    }
    
    fileprivate func move(at point:CGPoint) {
        if currentPath.appendPoint(point: point) {
            self.path = self.currentPath.cgPath
        }
    }
    
    fileprivate func end() {
        currentPath.end()
        self.path = currentPath.cgPath
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "path" || event == "contents" {
            return nil
        }
        return super.action(forKey: event);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TLStoryDoodleView: UIView {
    public var lineColor : UIColor = UIColor.white
    public var lineWidth : CGFloat = TLStoryConfiguration.defaultDrawLineWeight
    
    public var delegate : TLStoryDoodleViewDelegate?
    
    private var shapeLayers = [TLStoryDoodleLayer]()
    private var currenShapeLayer : TLStoryDoodleLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isMultipleTouchEnabled = false
    }
    
    public func undo() {
        if self.shapeLayers.count == 0 {
            return
        }
        
        let layer = self.shapeLayers.last
        layer?.removeFromSuperlayer()
        self.shapeLayers.removeLast()
    }
    
    public func erase() {
        self.shapeLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        self.shapeLayers.removeAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self)
        
        currenShapeLayer = TLStoryDoodleLayer.init()
        currenShapeLayer?.frame = bounds
        currenShapeLayer?.strokeColor = lineColor.cgColor
        currenShapeLayer?.lineWidth = 10
        
        self.layer.addSublayer(currenShapeLayer!)
        self.shapeLayers.append(currenShapeLayer!)
        
        currenShapeLayer?.begin(at: point)
        
        if let d = delegate {
            d.storyDoodleView(drawing: true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self)
        
        currenShapeLayer?.move(at: point)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchEndOrCancel()
        
        if let d = delegate {
            d.storyDoodleView(drawing: false)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchEndOrCancel()
        
        if let d = delegate {
            d.storyDoodleView(drawing: false)
        }
    }
    
    private func touchEndOrCancel() {
        currenShapeLayer?.end()
        currenShapeLayer = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
