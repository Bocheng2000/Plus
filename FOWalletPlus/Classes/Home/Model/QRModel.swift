//
//  QRModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class QRModel: NSObject {
    var value: String!
    var color: UIColor = UIColor.black
    var wh: CGFloat!
    var tip: String!
    convenience init(_ _value: String, _wh: CGFloat, _tip: String, _color: UIColor?) {
        self.init()
        value = _value
        wh = _wh
        tip = _tip
        if _color != nil {
            color = _color!
        }
    }
}
