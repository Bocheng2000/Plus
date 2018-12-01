//
//  LockTokenHeaderFooterView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/29.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class LockTokenHeaderFooterView: UITableViewHeaderFooterView {
    
    private var titleLabel: UILabel!
    
    open var text: String! {
        didSet {
            titleLabel.text = text
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    private func makeUI() {
        contentView.backgroundColor = UIColor.clear
        let tiner = UIView(frame: CGRect(x: 0, y: 11, width: 5, height: 18))
        tiner.backgroundColor = themeColor
        contentView.addSubview(tiner)
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.colorWithHexString(hex: "#333333")
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 20, y: 0, width: width - 40, height: height)
    }
}
