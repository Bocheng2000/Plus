//
//  SimpleWalletBaseModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/27.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class SimpleWalletBaseModel: FatherModel {
    var `protocol`: String!
    var version: String!
    var action: String!
    var expired: Int = 0
}

class SimpleWalletLoginModel: SimpleWalletBaseModel {
    var uuID: String!
    var loginUrl: String!
    var loginMemo: String = ""
}

class SimpleWalletPayModel: SimpleWalletBaseModel {
    var to: String!
    var amount: String!
    var contract: String!
    var symbol: String!
    var precision: Int = 0
    var desc: String = ""
}
