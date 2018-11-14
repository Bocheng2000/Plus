//
//  UIImage+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    func imageWithColor(color:UIColor, rect:CGRect)->UIImage{
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func imageWithBlurRadius(blurRadius: CGFloat) -> UIImage {
        var img: UIImage?
        autoreleasepool {
            let input = CIImage(image: self)
            let filter = CIFilter(name: "CIGaussianBlur")!
            filter.setValue(input, forKey: kCIInputImageKey)
            filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
            let out = filter.outputImage!
            let rect = CGRect(origin: CGPoint.zero, size: self.size)
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(out, from: rect)
            img = UIImage(cgImage: cgImage!)
        }
        if img != nil {
            return img!
        }
        return self
    }
}
