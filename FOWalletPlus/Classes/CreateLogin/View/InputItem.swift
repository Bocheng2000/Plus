//
//  InputItem.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol InputItemDelegate: NSObjectProtocol {
    @objc optional func inputItemBlur(sender: InputItem, isMatch: Bool)
    @objc optional func inputItemFocus(sender: InputItem)
}

class InputItem: UIView, UITextFieldDelegate {
    
    var titleLabel: UILabel!
    var textField: BaseTextField!
    weak var delegate: InputItemDelegate?
    
    public var model: InputItemModel! {
        didSet {
            setModel()
        }
    }
    
    // MARK: 设置Model
    private func setModel() {
        titleLabel.text = model.title
        if model.placeholder != nil {
            textField.placeholder = model.placeholder
        }
        if model.defaultValue != nil {
            textField.text = model.defaultValue
        }
        if model.isSecureTextEntry {
            textField.isSecureTextEntry = model.isSecureTextEntry
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel(frame: CGRect(x: 0, y: 9, width: width, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.colorWithHexString(hex: "#666666")
        addSubview(titleLabel)
        textField = BaseTextField(frame: CGRect(x: titleLabel.x, y: titleLabel.bottom + 7, width: titleLabel.width, height: 25))
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.setValue(UIColor.colorWithHexString(hex: "#CCCCCC"), forKeyPath: "_placeholderLabel.textColor")
        textField.delegate = self
        addSubview(textField)
        setBorderLine(position: .bottom, number: 0.5, color: UIColor.colorWithHexString(hex: "#0096DD"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: =====  UITextField Delegate ======
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.textColor = FONT_COLOR
        if delegate != nil {
            delegate?.inputItemFocus!(sender: self)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if model.regex != nil {
            let value = textField.text ?? ""
            if value != "" {
                if !value.match(regex: model.regex!) {
                    textField.textColor = ERROR_COLOR
                    invokeDelegate(false)
                    return
                }
            }
        }
        invokeDelegate(true)
    }
    
    private func invokeDelegate(_ isMatch: Bool) {
        if delegate != nil {
            delegate?.inputItemBlur!(sender: self, isMatch: isMatch)
        }
    }
}
