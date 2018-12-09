//
//  CustomFlowLayout.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CustomFlowLayout: XLPlainFlowLayout {
    override init() {
        super.init()
        self.naviHeight = naviHeight
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
