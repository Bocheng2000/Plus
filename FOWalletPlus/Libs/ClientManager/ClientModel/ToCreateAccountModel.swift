//
//  ToCreateAccountModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToCreateAccountModel: PkStringModel {
    var creator: String!
    var name: String!
    var pubKeyString: String!
    var bytes: UInt32?
    var stake_net_quantity: String?
    var stake_cpu_quantity: String?
    var transfer: Bool?
    convenience init(_ _creator: String, _name: String, _pubKeyString: String, _bytes: UInt32?, _stake_net_quantity: String?, _stake_cpu_quantity: String?, _transfer: Bool?) {
        self.init()
        creator = _creator
        name = _name
        pubKeyString = _pubKeyString
        bytes = _bytes
        stake_net_quantity = _stake_net_quantity
        stake_cpu_quantity = _stake_cpu_quantity
        transfer = _transfer
    }
}

class NewAccountModel: FatherModel {
    var creator: String!
    var name: String!
    var owner: AuthorityModel!
    var active: AuthorityModel!
    convenience init(_ _creator: String, _name: String, _key: String) {
        self.init()
        creator = _creator
        name = _name
        owner = AuthorityModel(_key)
        active = AuthorityModel(_key)
    }
}

class AuthorityModel: FatherModel {
    var threshold: Int32 = 1
    var keys: [AuthorityKeyModel]!
    convenience init(_ _key: String) {
        self.init()
        keys = [AuthorityKeyModel(_key)]
    }
}

class AuthorityKeyModel: FatherModel {
    var key: String!
    var weight: Int32 = 1
    var accounts: [AuthorityAccountsModel] = []
    var waits: [AuthorityWaitsModel] = []
    convenience init(_ _key: String) {
        self.init()
        key = _key
    }
}

class AuthorityAccountsModel: FatherModel {
    
}

class AuthorityWaitsModel: FatherModel {
    
}

class BuyRamBytesModel: FatherModel {
    var payer: String!
    var receiver: String!
    var bytes: UInt32 = 4096
    convenience init(_ _payer: String, _receiver: String, _bytes: UInt32?) {
        self.init()
        payer = _payer
        receiver = _receiver
        if _bytes != nil {
            bytes = _bytes!
        }
    }
}

