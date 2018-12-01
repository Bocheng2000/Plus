//
//  String+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation
import UIKit

extension String {
    public func getAttributeStringWithString(lineSpace:CGFloat
        ) -> NSAttributedString{
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStye = NSMutableParagraphStyle()
        paragraphStye.lineSpacing = lineSpace
        let rang = NSMakeRange(0, CFStringGetLength(self as CFString?)); attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStye, range: rang)
        return attributedString
    }
    
    func md5String() -> String {
        let str = self.cString(using: .utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate(capacity: digestLen)
        return String(hash)
    }
    
    func md5StringKey(key:String) -> String {
        let cKey = key.cString(using: .utf8)
        let cData = self.cString(using: .utf8)
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), cKey, strlen(cKey!), cData, strlen(cData!), &result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        return hash as String
    }
    
    func match(regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    func getTextSize(font: UIFont, lineHeight: CGFloat, maxSize: CGSize) -> CGSize {
        if self == "" {
            return CGSize(width: 0, height: 0)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributes = [NSAttributedStringKey.font:font, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = self.boundingRect(with: maxSize, options: option, attributes: attributes, context: nil).size
        return CGSize(width: size.width, height: size.height)
    }
    
    func trim() -> String {
        let characterSet = CharacterSet(charactersIn: " ")
        return self.trimmingCharacters(in: characterSet)
    }
    
    func trimAll() -> String {
        return self.split(separator: " ").joined(separator: "")
    }
    
    func charAt(index: Int) -> String {
        let i = self.index(self.startIndex, offsetBy: index)
        return String(self[i...i])
    }
    
    func toDecimal() -> Decimal {
        return Decimal(string: self) ?? Decimal(0)
    }

    func utcTime2Local(format: String?) -> String {
        let local = NSTimeZone.local
        let offset = local.secondsFromGMT()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let ts = fmt.date(from: self)?.timeIntervalSince1970
        if ts == nil {
            return ""
        }
        let localDate = Date(timeIntervalSince1970: TimeInterval(Int(ts!) + offset))
        if format == nil {
            return localDate.format(formatter: "yyyy/MM/dd")
        }
        return localDate.format(formatter: format!)
    }
}
