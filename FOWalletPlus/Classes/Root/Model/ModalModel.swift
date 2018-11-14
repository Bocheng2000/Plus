//
//  ConfirmModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

typealias handlerBlock = () -> Void

class ModalButtonModel: NSObject {
    var title: String!
    var titleColor: UIColor = BUTTON_COLOR
    var titleFont: UIFont = UIFont.systemFont(ofSize: 16)
    var backgroundColor: UIColor = UIColor.white
    var borderColor: UIColor = BUTTON_COLOR
    var handler: handlerBlock?
    override init() {
        super.init()
    }
    
    convenience init(_ _title: String, _titleColor: UIColor?, _titleFont: UIFont?, _backgroundColor: UIColor?, _borderColor: UIColor?, _handler: handlerBlock?) {
        self.init()
        title = _title
        if _titleColor != nil {
            titleColor = _titleColor!
        }
        if _titleFont != nil {
            titleFont = _titleFont!
        }
        if _backgroundColor != nil {
            backgroundColor = _backgroundColor!
        }
        if _borderColor != nil {
            borderColor = _borderColor!
        }
        handler = _handler
    }
}

class ModalModel: NSObject {
    var closeShow: Bool = true
    var imageName: String?
    var title: String!
    var message: String?
    var buttons: [ModalButtonModel]! = []
    override init() {
        super.init()
    }
    convenience init(_ _closeShow: Bool?, _imageName: String?, _title: String, _message: String?, _buttons: [ModalButtonModel]) {
        self.init()
        if _closeShow != nil {
            closeShow = _closeShow!
        }
        imageName = _imageName
        title = _title
        message = _message
        buttons = _buttons
    }
}
