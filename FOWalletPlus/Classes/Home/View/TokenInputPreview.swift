//
//  TokenInputPreview.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol TokenInputPreviewDelegate: NSObjectProtocol {
    @objc optional func tokenInputPreviewBlur(sender: TokenInputPreview)
    @objc optional func tokenInputPreviewFocus(sender: TokenInputPreview)
}

class TokenInputPreview: UIView, UITextFieldDelegate {
    
    weak var delegate: TokenInputPreviewDelegate?
    
    var titleLabel: UILabel!
    var desc: UILabel!
    var inputField: BaseTextField!
    var detail: UILabel!
    
    open var model: TokenInputModel! {
        didSet {
            setModel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let color: UIColor = UIColor.colorWithHexString(hex: "#666666")
        let font = UIFont.systemFont(ofSize: 14)
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = font
        titleLabel.textColor = color
        addSubview(titleLabel)
        desc = UILabel(frame: .zero)
        desc.font = font
        desc.textColor = color
        desc.textAlignment = .right
        addSubview(desc)
        inputField = BaseTextField(frame: .zero)
        inputField.clearButtonMode = .whileEditing
        inputField.autocorrectionType = .no
        inputField.autocapitalizationType = .none
        inputField.setValue(UIColor.colorWithHexString(hex: "#CCCCCC"), forKeyPath: "_placeholderLabel.textColor")
        inputField.delegate = self
        addSubview(inputField)
        
        detail = UILabel(frame: .zero)
        detail.font = font
        detail.textColor = UIColor.colorWithHexString(hex: "#AAB3B3")
        addSubview(detail)
        setBorderLine(position: .bottom, number: 0.5, color: UIColor.colorWithHexString(hex: "#0096DD"))
    }
    
    private func setModel() {
        let titleSize = model.title.getTextSize(font: titleLabel.font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
        titleLabel.frame = CGRect(x: 0, y: 10, width: titleSize.width, height: 20)
        titleLabel.text = model.title
        if model.desc != nil {
            desc.frame = CGRect(x: titleSize.width + 10, y: titleLabel.top, width: width - titleSize.width - 10, height: titleLabel.height)
            desc.text = model.desc!
        } else {
            desc.removeFromSuperview()
        }
        if model.detailValue == nil {
            detail.removeFromSuperview()
            inputField.frame = CGRect(x: 0, y: titleLabel.bottom + 5, width: width, height: 25)
        } else {
            let detailSize = model.detailValue!.getTextSize(font: detail.font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
            detail.frame = CGRect(x: width - detailSize.width, y: titleLabel.bottom + 5, width: detailSize.width, height: 25)
            detail.text = model.detailValue
            inputField.frame = CGRect(x: 0, y: detail.top, width: width - detailSize.width - 10, height: 25)
        }
        if model.placeholder != nil {
            inputField.placeholder = model.placeholder!
        }
        if model.defaultValue != nil {
            inputField.text = model.defaultValue
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let value = (textField.text ?? "") + string
        if model.maxLength != nil {
            return value.count <= model.maxLength!
        }
        if model.precision != nil {
            let split = value.split(separator: ".")
            if split.count == 0 {
                return true
            }
            if split.count == 1 {
                return true
            }
            if split.count == 2 {
                return String(split[1]).count <= model.precision!
            }
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if delegate != nil {
            delegate?.tokenInputPreviewFocus!(sender: self)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if delegate != nil {
            delegate?.tokenInputPreviewBlur!(sender: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
