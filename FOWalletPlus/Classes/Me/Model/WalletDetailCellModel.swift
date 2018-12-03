//
//  WalletDetailCellModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/3.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WalletDetailCellModel: NSObject {
    var title: String!
    var value: String?
    var type: UITableViewCellAccessoryType = .none
    convenience init(_ _title: String, _value: String?, _type: UITableViewCellAccessoryType) {
        self.init()
        title = _title
        value = _value
        type = _type
    }
}
