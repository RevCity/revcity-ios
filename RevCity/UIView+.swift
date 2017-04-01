//
//  UIView+.swift
//  RevCity
//
//  Created by Joseph Antonakakis on 4/1/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit

extension UIView {
    
    func resizeToFitSubviews() -> Void {
        var w : CGFloat = 0.0
        var h : CGFloat = 0.0
        for v in self.subviews {
            let fw : CGFloat = v.frame.origin.x + v.frame.size.width
            let fh : CGFloat = v.frame.origin.y + v.frame.size.height
            w = max(w, fw)
            h = max(h, fh)
        }
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: w, height: h)
    }
}
