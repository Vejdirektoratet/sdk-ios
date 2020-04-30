//
//  ImageExtension.swift
//  Examples
//
//  Created by Daniel Andersen on 21/11/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static func resize(image: UIImage, size: CGSize) -> UIImage {
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
