//
//  Wallet.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class Wallet: NSObject {
    var account: String!
    var prompt: String!
    var pubKey: String!
    var password: String!
    var priKeyEncode: String!
    
    /// 初始化钱包对象
    ///
    /// - Parameters:
    ///   - _account: 账户名
    ///   - _prompt: 提示
    ///   - _pubKey: 公钥
    ///   - _password: 密码
    ///   - _priKey: 私钥
    ///   - isEncode: 是否已经加过密了
    convenience init(_ _account: String, _prompt: String, _pubKey: String,
                     _password: String, _priKey: String, isEncode: Bool) {
        self.init()
        let AES = CryptoJS.AES()
        account = _account
        prompt = _prompt
        pubKey = _pubKey
        if isEncode {
            password = _password
            priKeyEncode = _priKey
        } else {
            password = _password.md5String()
            priKeyEncode = AES.encrypt(_priKey, password: password)
        }
    }
    
    open func verifyPassword(_ nextPwd: String) -> Bool {
        if nextPwd == "" {
            return false
        }
        return password == nextPwd.md5String()
    }
    
    open func getPriKey(_ nextPwd: String) -> String? {
        if verifyPassword(nextPwd) {
            let AES = CryptoJS.AES()
            return AES.decrypt(priKeyEncode, password: password)
        }
        return nil
    }
    
}
