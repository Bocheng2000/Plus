//
//  InputItemMulit.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol InputItemMulitDelegate: NSObjectProtocol {
    @objc optional func inputItemMulitBlur(sender: InputItemMulit, isMatch: Bool)
}

class InputItemMulit: UIView, UITextViewDelegate {
    var titleLabel: UILabel!
    var textView: AutoHeightTextView!
    weak var delegate: InputItemMulitDelegate?
    
    public var model: InputItemModel! {
        didSet {
            setModel()
        }
    }
    
    // MARK: 设置Model
    private func setModel() {
        titleLabel.text = model.title
        if model.placeholder != nil {
            textView.placeholder = model.placeholder ?? ""
        }
        if model.defaultValue != nil {
            textView.text = model.defaultValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel(frame: CGRect(x: 0, y: 9, width: width, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.colorWithHexString(hex: "#666666")
        addSubview(titleLabel)
        textView = AutoHeightTextView(frame: CGRect(x: titleLabel.x, y: titleLabel.bottom + 7, width: titleLabel.width, height: 45))
        textView.autoHeight = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.delegate = self
        addSubview(textView)
        setBorderLine(position: .bottom, number: 0.5, color: lineColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if delegate != nil {
            delegate?.inputItemMulitBlur!(sender: self, isMatch: true)
        }
    }
    
}
