//
//  ToUnDelegateBWModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToUnDelegateBWModel: PkStringModel {
    var from: String!
    var receiver: String!
    var unstake_cpu_quantity: String!
    var unstake_net_quantity: String!
    convenience init(_ _from: String, _receiver: String, _unstake_net_quantity: String, _unstake_cpu_quantity: String) {
        self.init()
        from = _from
        receiver = _receiver
        unstake_net_quantity = _unstake_net_quantity
        unstake_cpu_quantity = _unstake_cpu_quantity
    }
}

class UnDelegateBWModel: FatherModel {
    var from: String!
    var receiver: String!
    var unstake_cpu_quantity: String = "0.0000 FO"
    var unstake_net_quantity: String = "0.0000 FO"
    convenience init(_ _from: String, _receiver: String, _unstake_cpu_quantity: String?, _unstake_net_quantity: String) {
        self.init()
        from = _from
        receiver = _receiver
        if _unstake_cpu_quantity != nil {
            unstake_cpu_quantity = _unstake_cpu_quantity!
        }
        unstake_net_quantity = _unstake_net_quantity
    }
}
