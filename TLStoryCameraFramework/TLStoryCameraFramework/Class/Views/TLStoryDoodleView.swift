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

class TLStoryDoodleView: UIView {
    public weak var delegate:TLStoryDoodleViewDelegate?
    fileprivate var lines = [[Any]]()
    fileprivate var purePoints = [Any]()
    fileprivate var previousPoint:CGPoint?
    fileprivate var previousPreviousPoint:CGPoint?
    fileprivate var currentPoint:CGPoint?
    fileprivate let distanceForDraw:CGFloat = 25
    fileprivate var isEnd = false
    fileprivate var isUndo = false
    fileprivate var isErase = false
    public      var lineWidth:CGFloat = TLStoryConfiguration.defaultDrawLineWeight
    public      var lineColor:UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        isUserInteractionEnabled = true
        isExclusiveTouch = true
        isMultipleTouchEnabled = true
    }
    
    public func undo() {
        guard lines.count > 0 else {
            return
        }
        isUndo = true
        lines.removeLast()
        setNeedsDisplay()
    }
    
    public func erase() {
        isErase = true
        lines.removeAll()
        purePoints.removeAll()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context!)
        
        if isUndo {
            isUndo = false
            var j = 0
            while j < lines.count {
                let points = lines[j]
                if points.count % 2 == 0 {
                    continue
                }
                drawLine(context: context, lins: points)
                j += 1
            }
            
            return
        }
        
        if isErase {
            isErase = false
            context?.clear(self.bounds)
        }
        
        guard purePoints.count != 0 else {
            return
        }
        
        guard purePoints.count % 2 != 0 else {
            return
        }
        
        drawLine(context: context, lins: purePoints)
    }
    
    fileprivate func drawLine(context:CGContext?,lins:[Any]) {
        let arr = lins
        let width = (arr[0] as! [Any])[0] as! CGFloat
        let color = (arr[0] as! [Any])[1] as! CGColor
        
        context?.setLineWidth(width)
        context?.setLineCap(.round)
        context?.beginPath()
        context?.setStrokeColor(color)
        
        let count = (arr.count - 1) / 2
        
        var point_c:CGPoint?
        var point_p:CGPoint?
        
        var i = 0
        while i < count {
            let x = arr[2 * i + 1] as! CGFloat
            let y = arr[2 * i + 2] as! CGFloat
            
            if i == 0 {
                point_c = CGPoint.init(x: x, y: y)
                
                context?.move(to: point_c!)
                
                if count == 1 {
                    context?.addQuadCurve(to: point_c!, control: point_c!)
                }
            }else if (i == count - 1) && isEnd {
                point_p = point_c
                point_c = CGPoint.init(x: x, y: y)
                
                context?.addQuadCurve(to: point_c!, control: point_p!)
            }else {
                point_p = point_c
                point_c = CGPoint.init(x: x, y: y)
                
                let mid2 = midPoint(p1: point_c!, p2: point_p!)
                context?.addQuadCurve(to: mid2, control: point_p!)
            }
            
            i += 1
        }
        
        context?.strokePath()
    }
    
    fileprivate func midPoint(p1:CGPoint, p2:CGPoint) -> CGPoint {
        return CGPoint.init(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
    
    fileprivate func distanceBetweenP1(p1:CGPoint, p2:CGPoint) -> CGFloat {
        return CGFloat(powf(Float((p1.x - p2.x)), 2) + powf(Float((p1.y - p2.y)), 2))
    }
    
    fileprivate func getCurImageFromBounds(_ bounds:CGRect) {
        var drawBox = bounds
        drawBox.origin.x     -= lineWidth * 2;
        drawBox.origin.y     -= lineWidth * 2;
        drawBox.size.width   += lineWidth * 4;
        drawBox.size.height  += lineWidth * 4;
        
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: drawBox.size)
            renderer.image { (context) in
                UIGraphicsBeginImageContext(size)
                self.layer.render(in: context.cgContext)
                UIGraphicsEndImageContext()
            }
        } else {
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            self.layer.render(in: context!)
            UIGraphicsEndImageContext()
        }
        
        self.setNeedsDisplay(drawBox)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        purePoints.removeAll()
        let touch = (touches as NSSet).anyObject() as! UITouch
        previousPoint = touch.previousLocation(in: self)
        previousPreviousPoint = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        
        purePoints.append([lineWidth,lineColor.cgColor])
        purePoints.append(currentPoint?.x ?? 0)
        purePoints.append(currentPoint?.y ?? 0)
        
        isEnd = false
        
        self.delegate?.storyDoodleView(drawing: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        
        let point = touch.location(in: self)
        
        let dx = point.x - (currentPoint?.x)!
        let dy = point.y - (currentPoint?.y)!
        
        if ((dx * dx + dy * dy) < distanceForDraw) {
            return
        }
        
        previousPreviousPoint = previousPoint
        previousPoint = currentPoint
        currentPoint = touch.location(in: self)
        
        let mid1 = midPoint(p1: previousPoint!, p2: previousPreviousPoint!)
        let mid2 = midPoint(p1: currentPoint!, p2: previousPoint!)
        
        let path_ = CGMutablePath()
        path_.move(to: mid1)
        path_.addQuadCurve(to: mid2, control: previousPoint!)
        
        purePoints.append(currentPoint?.x ?? 0)
        purePoints.append(currentPoint?.y ?? 0)
        
        getCurImageFromBounds(path_.boundingBox)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelOrEnd(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelOrEnd(touches, with: event)
    }
    
    fileprivate func touchesCancelOrEnd(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard purePoints.count % 2 != 0 else {
            return
        }
        
        let touch = (touches as NSSet).anyObject() as! UITouch
        
        previousPreviousPoint = previousPoint
        previousPoint = currentPoint
        currentPoint = touch.location(in: self)
        
        let mid1 = midPoint(p1: previousPoint!, p2: previousPreviousPoint!)
        
        let path_ = CGMutablePath()
        path_.move(to: mid1)
        path_.addQuadCurve(to: currentPoint!, control: previousPoint!)
        
        var needAddPoints = true
        if purePoints.count == 3 {
            let p1 = CGPoint.init(x: purePoints[1] as! CGFloat, y: purePoints[2] as! CGFloat)
            let distance = distanceBetweenP1(p1: p1, p2: currentPoint!)
            
            if distance < distanceForDraw {
                needAddPoints = false
            }
        }
        
        if needAddPoints,let p = currentPoint {
            purePoints.append(p.x)
            purePoints.append(p.y)
        }
        
        lines.append(purePoints)
        
        isEnd = true
        
        getCurImageFromBounds(path_.boundingBox)
        
        self.delegate?.storyDoodleView(drawing: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
