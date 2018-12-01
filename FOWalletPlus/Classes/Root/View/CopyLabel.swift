//
//  CopyLabel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CopyLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        make()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        make()
    }
    
    private func make() {
        isUserInteractionEnabled = true
        becomeFirstResponder()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showMenu))
        addGestureRecognizer(longPress)
    }
    
    @objc private func showMenu() {
        let copyText = LanguageHelper.localizedString(key: "Copy")
        let copyItem = UIMenuItem(title: copyText, action: #selector(toCopy))
        let menu = UIMenuController.shared
        menu.menuItems = [copyItem]
        if menu.isMenuVisible {
            return
        }
        menu.setTargetRect(frame, in: superview!)
        menu.setMenuVisible(true, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(toCopy)
    }
    
    @objc private func toCopy() {
        UIPasteboard.general.string = text?.trimAll()
    }
}
