//
//  ToUnDelegateRamModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToUnDelegateRamModel: PkStringModel {
    var account: String!
    var bytes: String!
    convenience init(_ _account: String, _bytes: String) {
        self.init()
        account = _account
        bytes = _bytes
    }
}

class UnDelegateRamModel: FatherModel {
    var account: String!
    var bytes: String!
    convenience init(_ _account: String, _bytes: String) {
        self.init()
        account = _account
        bytes = _bytes
    }
}
