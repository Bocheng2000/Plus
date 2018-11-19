//
//  TokenDetailModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenDetailModel: NSObject {
    var symbol: String!
    var contract: String!
    convenience init(_ _symbol: String, _contract: String) {
        self.init()
        symbol = _symbol
        contract = _contract
    }
}
