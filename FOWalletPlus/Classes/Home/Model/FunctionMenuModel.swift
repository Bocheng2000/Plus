//
//  FunctionMenuModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

typealias functionMenuClick = () -> Void

class FunctionMenuModel: NSObject {
    var icon: String!
    var title: String!
    var handler: functionMenuClick!
    convenience init(_ _icon: String, _title: String, _handler: @escaping functionMenuClick) {
        self.init()
        icon = _icon
        title = _title
        handler = _handler
    }
}
