//
//  UIView+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation
import UIKit

enum Position{
    case left
    case right
    case top
    case bottom
}

extension UIView {
    /**
     * X
     */
    var x: CGFloat{
        get{
            return frame.origin.x
        }
        set(newVal){
            var sourceFrame: CGRect = frame
            sourceFrame.origin.x = newVal
            frame = sourceFrame
        }
    }
    
    /**
     * Y
     */
    var y: CGFloat{
        get{
            return frame.origin.y
        }
        set(newVal){
            var sourceFrame:CGRect = frame
            sourceFrame.origin.y = newVal
            frame = sourceFrame
        }
    }
    
    /**
     * width
     */
    var width: CGFloat{
        get{
            return frame.size.width
        }
        set(newVal){
            var sourceFrame: CGRect = frame
            sourceFrame.size.width = newVal
            frame = sourceFrame
        }
    }
    
    /**
     * height
     */
    var height: CGFloat{
        get{
            return frame.size.height
        }
        set(newVal){
            var sourceFrame: CGRect = frame
            sourceFrame.size.height = newVal
            frame = sourceFrame
        }
    }
    
    /**
     * right
     */
    var right: CGFloat{
        get{
            return x + width
        }
        set(newVal){
            x = newVal - width
        }
    }
    
    /**
     * top
     */
    var top: CGFloat{
        get{
            return y
        }
        set(newVal){
            y = newVal
        }
    }
    
    /**
     * bottom
     */
    var bottom: CGFloat{
        get{
            return y + height
        }
        set(newVal){
            y = newVal - height
        }
    }
    
    /**
     * centerX
     */
    var centerX: CGFloat{
        get{
            return center.x
        }
        set(newVal){
            center = CGPoint(x: newVal, y: center.y)
        }
    }
    
    /**
     * centerY
     */
    var centerY: CGFloat{
        get{
            return center.y
        }
        set(newVal){
            center = CGPoint(x: center.x, y: newVal)
        }
    }
    
    /**
     * middleX
     */
    var middleX: CGFloat{
        get{
            return width / 2
        }
    }
    
    /**
     * middleY
     */
    var middleY: CGFloat{
        get{
            return height / 2
        }
    }
    
    /**
     * middlePoint
     */
    var middlePoint: CGPoint{
        get{
            return CGPoint(x: middleX, y: middleY)
        }
    }
    
    func setBorderLine(position: Position, number: CGFloat, color: UIColor) {
        let layer = CALayer()
        switch position {
        case Position.top:
            layer.frame = CGRect(x: 0, y: 0, width: self.width, height: number)
            break
        case Position.bottom:
            layer.frame = CGRect(x: 0, y: self.height - number, width: self.width, height: number)
            break
        case Position.left:
            layer.frame = CGRect(x: 0, y: 0, width: number, height: self.height)
            break
        default:
            layer.frame = CGRect(x: self.width - number, y: 0, width: number, height: self.height)
        }
        layer.backgroundColor = color.cgColor
        self.layer.addSublayer(layer)
    }
    
}
