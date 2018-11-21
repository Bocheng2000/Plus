//
//  BaseTextField.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/20.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class BaseTextField: UITextField {
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 40))
        let btn = UIButton(frame: CGRect(x: kSize.width - 60, y: 0, width: 50, height: 40))
        btn.setTitle(LanguageHelper.localizedString(key: "Done"), for: .normal)
        btn.setTitleColor(UIColor.colorWithHexString(hex: "#666666"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.contentHorizontalAlignment = .right
        toolBar.setItems([UIBarButtonItem(customView: btn)], animated: true)
        inputAccessoryView = toolBar
        btn.addTarget(self, action: #selector(doneBtnDidClick), for: .touchUpInside)
    }
    
    @objc private func doneBtnDidClick() {
        endEditing(true)
    }
}
