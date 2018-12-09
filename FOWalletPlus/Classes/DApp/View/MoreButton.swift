//
//  MoreButton.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class MoreButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = CGRect(x: width - 12, y: (height - 12) / 2, width: 12, height: 12)
        titleLabel?.frame = CGRect(x: 0, y: (height - 12) / 2, width: width - 12, height: 12)
    }
}
