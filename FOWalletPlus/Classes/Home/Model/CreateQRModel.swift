//
//  CreateQRModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CreateQRModel: FatherModel {
    var target: String!
    var params: String!
    convenience init(_ _target: String, _params: String) {
        self.init()
        target = _target
        params = _params
    }
}
