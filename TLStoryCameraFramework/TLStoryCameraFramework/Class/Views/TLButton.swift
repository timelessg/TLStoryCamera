//
//  TLButton.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class TLButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds;
        let widthDelta = max(44.0 - bounds.size.width, 0)
        let heightDelta = max(44.0 - bounds.size.height, 0);
        bounds = bounds.insetBy(dx: -0.5 * widthDelta, dy: -0.5 * heightDelta);
        return bounds.contains(point)
    }
}
