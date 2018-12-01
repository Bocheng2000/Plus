//
//  CopyButton.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/30.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CopyButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    private func setUp() {
        setImage(UIImage(named: "copy"), for: .normal)
        addTarget(self, action: #selector(btnDidClick), for: .touchUpInside)
    }
    
    @objc private func btnDidClick() {
        UIPasteboard.general.string = titleLabel?.text
        let info = LanguageHelper.localizedString(key: "CopySuccess")
        ZSProgressHUD.showDpromptText(info)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.x = 0
        imageView?.x = (titleLabel?.right)! + 8
    }
}
