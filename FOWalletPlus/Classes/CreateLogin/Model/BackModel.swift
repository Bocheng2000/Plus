//
//  BackModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class BackModel: NSObject {
    var account: String!
    var password: String!
    var prompt: String = ""
    var pubKey: String = ""
    var priKey: String = ""
    init(_ _account: String, _password: String, _prompt: String?) {
        super.init()
        account = _account
        password = _password
        prompt = _prompt ?? ""
    }
    
    init(_ _account: String, _password: String, _prompt: String?, _pubKey: String, _priKey: String) {
        super.init()
        account = _account
        password = _password
        prompt = _prompt ?? ""
        pubKey = _pubKey
        priKey = _priKey
    }
    
    override init() {
        super.init()
    }
}
