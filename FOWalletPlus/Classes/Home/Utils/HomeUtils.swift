//
//  HomeUtils.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class HomeUtils: NSObject {
    
    /// 根据字符串的长度获取字体大小
    ///
    /// - Parameter text: 输入字符串
    /// - Returns: 字体大小
    open class func getTextSize(_ text: String) -> CGFloat {
        if (text.count <= 12) {
            return 30
        } else if (text.count <= 15) {
            return 28
        } else if (text.count <= 18) {
            return 26
        } else if (text.count <= 21) {
            return 24
        }
        return 22
    }
    
    
    /// 获取Symbol
    ///
    /// - Parameter text: 输入字符串
    /// - Returns: Symbol
    open class func getSymbol(_ text: String) -> String {
        let split = text.split(separator: " ")
        if split.count > 1 {
            return String(split[1])
        }
        return ""
    }
    
    /// 获取Quantity
    ///
    /// - Parameter text: 输入字符串
    /// - Returns: Quantity
    open class func getQuantity(_ text: String) -> String {
        let split = text.split(separator: " ")
        return String(split[0])
    }
    
    /// 组装通证
    ///
    /// - Parameters:
    ///   - symbol: 通证名
    ///   - contract: 合约名
    /// - Returns: 通证全名
    open class func getExtendSymbol(_ symbol: String, contract: String) -> String {
        return "\(symbol)@\(contract)"
    }
    
    /// 格式化数量
    ///
    /// - Parameter text: 输入字符串
    /// - Returns: 格式化后的数据
    open class func fmtQuantity(_ text: String) -> String {
        let quantity = String(text.split(separator: " ")[0])
        let split = quantity.split(separator: ".")
        let left = String(split[0])
        var chars: [String] = []
        var idx: Int = 0
        for i in (0...(left.count - 1)).reversed() {
            chars.append(left.charAt(index: i))
            if idx % 3 == 2 && i != 0 {
                chars.append(",")
            }
            idx += 1
        }
        let preStr = chars.reversed().joined(separator: "")
        if split.count > 1 {
            return "\(preStr).\(split[1])"
        }
        return String(preStr)
    }
}
