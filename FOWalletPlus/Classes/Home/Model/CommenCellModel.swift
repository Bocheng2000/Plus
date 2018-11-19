//
//  CommenCellModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/18.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CommenCellModel: NSObject {
    var icon: String!
    var title: String!
    var value: String!
    var showArrow: Bool!
    var target: String?
    convenience init(_ _icon: String, _title: String, _value: String, _showArrow: Bool?, _target: String?) {
        self.init()
        icon = _icon
        title = _title
        value = _value
        if _showArrow == nil {
            showArrow = true
        } else {
            showArrow = _showArrow!
        }
        target = _target
    }
}
