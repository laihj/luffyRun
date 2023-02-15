//
//  ColorExt.swift
//  luffyRun
//
//  Created by laihj on 2023/2/15.
//

import Foundation
import UIKit

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
        return UIColor(hexString: "#03C988")
    }
    
    class var zone2Color: UIColor {
        return UIColor(hexString: "#FFD124")
    }
    
    class var zone3Color: UIColor {
        return UIColor(hexString: "#2155CB")
    }
    
    class var zone4Color: UIColor {
        return UIColor(hexString: "#FF5677")
    }
    
    class var zone5Color: UIColor {
        return UIColor(hexString: "#9145B6")
    }
}

