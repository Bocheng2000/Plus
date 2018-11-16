//
//  MenuButton.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class MenuButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    private func makeUI() {
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }
    
    open func resize() {
        imageEdgeInsets = UIEdgeInsetsMake(-(height - (imageView?.height ?? 0)) + 10, 0, 0, -(titleLabel?.width ?? 0))
        titleEdgeInsets = UIEdgeInsetsMake(-10, -(imageView?.width ?? 0), -(height - (titleLabel?.height ?? 0)), 0)
    }
}
