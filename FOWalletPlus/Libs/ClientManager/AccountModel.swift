//
//  CurrentAccountModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AccountModel: NSObject {
    var account: String!
    var pubKey: String!
    var endPoint: String?
    var backUp: Bool?
    convenience init(_ _account: String, _pubKey: String!) {
        self.init()
        account = _account
        pubKey = _pubKey
    }
}
