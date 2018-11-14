//
//  InputItemModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class InputItemModel: NSObject {
    var title: String!
    var placeholder: String?
    var defaultValue: String?
    var regex: String?
    var isSecureTextEntry: Bool = false
    init(_ _title: String, _placeholder: String?, _defaultValue: String?, _regex: String?, _isSecureTextEntry: Bool) {
        super.init()
        title = _title
        placeholder = _placeholder
        defaultValue = _defaultValue
        regex = _regex
        isSecureTextEntry = _isSecureTextEntry
    }
}
