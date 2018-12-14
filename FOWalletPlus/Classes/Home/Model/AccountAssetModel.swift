//
//  AccountAssetModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/16.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AccountAssetModel: FatherModel {
    var primary: Int32!
    var belong: String!
    var contract: String!
    var hide: Bool!
    var quantity: String!
    var lockToken: String!
    var contractWallet: String!
    var isSmart: Bool!
    var symbol: String! {
        get {
            return HomeUtils.getSymbol(quantity)
        }
    }
    convenience init(_ _primary: Int32, _belong: String, _contract: String, _hide: Bool, _quantity: String, _lockToken: String, _contractWallet: String, _isSmart: Bool) {
        self.init()
        primary = _primary
        belong = _belong
        contract = _contract
        hide = _hide
        quantity = _quantity
        lockToken = _lockToken
        contractWallet = _contractWallet
        isSmart = _isSmart
    }
}
