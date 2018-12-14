//
//  String+Camel+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/11.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation

extension String {
    private var camelName:String {
        var result = ""
        var flag = false
        self.forEach { c in
            let s = String(c)
            if s == "_" {
                flag = true
            } else {
                if flag {
                    result += s.uppercased()
                    flag = false
                } else {
                    result += s
                }
            }
        }
        return result
    }
    
    private var underscore_name:String {
        var result = ""
        self.forEach { c in
            let num = c.unicodeScalars.map { $0.value }.last!
            let s = String(c)
            if num > 64 && num < 91 {
                result += "_"
                result += s.lowercased()
            } else {
                result += s
            }
        }
        return result
    }
    
    enum JsonKeyType {
        case camel, underscore
    }
    
    func convertJsonKeyName(_ keyType: JsonKeyType) -> String {
        let pattern = "[\"' ]*[^:\"' ]*[\"' ]*:"
        var nsStr = self as NSString
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            // TODO: - 优化
            var res = regex.matches(in: nsStr as String, options:[NSRegularExpression.MatchingOptions(rawValue: 0)], range: NSMakeRange(0, (nsStr as NSString).length)) // 获取总位置数目
            for i in 0..<res.count {
                // 获取新位置
                res = regex.matches(in: nsStr as String, options:[NSRegularExpression.MatchingOptions(rawValue: 0)], range: NSMakeRange(0, (nsStr as NSString).length)) //str.count
                let c = res[i]
                let cStr = (nsStr as NSString).substring(with: c.range)
                let newStr = keyType == .camel ? cStr.camelName : cStr.underscore_name
                nsStr = nsStr.replacingCharacters(in: c.range, with: newStr) as NSString
            }
            
        } catch {
            print(error)
        }
        return nsStr as String
    }
}
