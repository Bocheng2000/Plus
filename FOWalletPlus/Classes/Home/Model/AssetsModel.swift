//
//  AvailableAssetsModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/16.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AssetsModel: NSObject, Codable {
    var primary: Int32!
    var balance: BalanceModel!
    var lock_timestamp: String?
    
    enum CodingKeys : String, CodingKey {
        case primary
        case balance
        case lock_timestamp = "lockTimestamp"
    }
    
    convenience init(_ _primary: Int32, _balance: BalanceModel, _lock_timestamp: String?) {
        self.init()
        primary = _primary
        balance = _balance
        lock_timestamp = _lock_timestamp
    }
}

class BalanceModel: NSObject, Codable {
    var quantity: String!
    var contract: String!
    convenience init(_ _quantity: String, _contract: String) {
        self.init()
        quantity = _quantity
        contract = _contract
    }
}
