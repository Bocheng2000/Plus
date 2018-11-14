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
        let rang = NSMakeRange(0, CFStringGetLength(self as CFString!)); attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStye, range: rang)
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
    
    func firstPy() -> String {
        let transformContents = CFStringCreateMutableCopy(nil, 0, self as CFString)
        CFStringTransform(transformContents, nil, kCFStringTransformMandarinLatin, false)
        let traStr:String = transformContents! as String
        let firstIndex = traStr.index(traStr.startIndex, offsetBy:1)
        let first = String(traStr[..<firstIndex]).uppercased()
        if first.match(regex: "[A-Z]") {
            return first
        }
        return "#"
    }
    
    func trim() -> String {
        let characterSet = CharacterSet(charactersIn: " ")
        return self.trimmingCharacters(in: characterSet)
    }
    
    func trimAll() -> String {
        return self.split(separator: " ").joined(separator: "")
    }
    
    func isPhone() -> Bool {
        return self.match(regex: "(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}")
    }
    
    func isEmail() -> Bool {
        return self.match(regex: "^[A-Za-z0-9\\u4e00-\\u9fa5]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$")
    }
    
    func isCode() -> Bool {
        return self.match(regex: "^\\d{6}$")
    }
}
