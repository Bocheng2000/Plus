//
//  WhichModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WhichModel: NSObject {
    var title: String!
    var type: UITableViewCellAccessoryType!
    convenience init(_ _title: String, _type: UITableViewCellAccessoryType) {
        self.init()
        title = _title
        type = _type
    }
}
