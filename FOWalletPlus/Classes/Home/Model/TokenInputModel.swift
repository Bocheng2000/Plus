//
//  TokenInputModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenInputModel: NSObject {
    var title: String!
    var desc: String?
    var maxLength: Int?
    var defaultValue: String?
    var placeholder: String?
    var detailValue: String?
    var precision: Int?
    
    convenience init(_ _title: String, _desc: String?, _maxLength: Int?, _defaultValue: String?, _placeholder: String?, _detailValue: String?, _precision: Int?) {
        self.init()
        title = _title
        desc = _desc
        maxLength = _maxLength
        defaultValue = _defaultValue
        placeholder = _placeholder
        detailValue = _detailValue
        precision = _precision
    }
}
