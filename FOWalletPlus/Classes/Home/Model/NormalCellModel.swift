//
//  NormalCellModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class NormalCellModel: NSObject {
    var title: String!
    var value: String!
    convenience init(_ _title: String, _value: String) {
        self.init()
        title = _title
        value = _value
    }
}
