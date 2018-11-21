//
//  ToDelegateBWModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToDelegateBWModel: PkStringModel {
    var from: String!
    var receiver: String!
    var stake_net_quantity: String = "0.0000 FO"
    var stake_cpu_quantity: String = "0.0000 FO"
    var transfer: Bool!
    convenience init(_ _from: String, _receiver: String, _stake_net_quantity: String?, _stake_cpu_quantity: String?, _transfer: Bool) {
        self.init()
        from = _from
        receiver = _receiver
        if _stake_net_quantity != nil {
            stake_net_quantity = _stake_net_quantity!
        }
        if _stake_cpu_quantity != nil {
            stake_cpu_quantity = _stake_cpu_quantity!
        }
        transfer = _transfer
    }
}

class DelegateBWModel: FatherModel {
    var from: String!
    var receiver: String!
    var stake_net_quantity: String!
    var stake_cpu_quantity: String!
    var transfer: Int = 1
    convenience init(_ _from: String, _receiver: String, _stake_net_quantity: String, _stake_cpu_quantity: String, _transfer: Bool?) {
        self.init()
        from = _from
        receiver = _receiver
        stake_net_quantity = _stake_net_quantity
        stake_cpu_quantity = _stake_cpu_quantity
        if _transfer != nil {
            transfer = _transfer! ? 1 : 0
        }
    }
}
