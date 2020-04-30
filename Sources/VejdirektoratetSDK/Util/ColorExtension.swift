//
//  ColorExtension.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 13/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIColor {
    static func colorWithHexString(hexString: String) -> UIColor {
        let hexint = Int64(ColorUtil.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff000000) >> 24) / 255.0
        let green = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let blue = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let alpha = CGFloat((hexint & 0xff) >> 0) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#else
import AppKit

extension NSColor {
    static func colorWithHexString(hexString: String) -> NSColor {
        let hexint = Int(ColorUtil.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff000000) >> 24) / 255.0
        let green = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let blue = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let alpha = CGFloat((hexint & 0xff) >> 0) / 255.0

        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#endif

private class ColorUtil {
    public static func intFromHexString(hexStr: String) -> UInt64 {
        var hexInt: UInt64 = 0

        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)
        
        return hexInt
    }
}
