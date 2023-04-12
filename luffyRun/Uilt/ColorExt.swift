//
//  ColorExt.swift
//  luffyRun
//
//  Created by laihj on 2023/2/15.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    class var mePurple: UIColor {
        return UIColor(hexString: "#9460ee")
    }
    
    class var zone1Color: UIColor {
        return UIColor(hexString: "#e0d8fc")
    }
    
    class var zone2Color: UIColor {
        return UIColor(hexString: "#b090f5")
    }
    
    class var zone3Color: UIColor {
        return UIColor(hexString: "#8843e4")
    }
    
    class var zone4Color: UIColor {
        return UIColor(hexString: "#6528af")
    }
    
    class var zone5Color: UIColor {
        return UIColor(hexString: "#341461")
    }
    
    class var textPrimaryColor: UIColor {
        return UIColor(hexString: "#4A4A4A")
    }
    
    class var textSecondaryColor: UIColor {
        return UIColor(hexString: "#878787")
    }
    
    class var textPrimary: Color {
        Color(UIColor.textPrimaryColor)
    }
    
    class var textSecondary: Color {
        Color(UIColor.textSecondaryColor)
    }
    
    class func zoneColor(zone:Zone) -> UIColor {
        switch(zone) {
        case .zone1:
            return zone1Color
        case .zone2:
            return zone2Color
        case .zone3:
            return zone3Color
        case .zone4:
            return zone4Color
        case .zone5:
            return zone5Color
        }
    }
}

