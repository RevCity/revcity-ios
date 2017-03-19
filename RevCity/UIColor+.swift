//
//  UIColor+.swift
//  RevCity
//
//  Created by Joseph Antonakakis on 3/19/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    @nonobjc static let facebookBlue = UIColor.colorFromCode(0x2C3E7A)
    // TODO - add more
    

    
    /** Color from hexidecimal code **/
    public static func colorFromCode(_ code: Int) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
