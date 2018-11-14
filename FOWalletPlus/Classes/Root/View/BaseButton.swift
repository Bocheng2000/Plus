//
//  BaseButton.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class BaseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addEvent()
    }
    
    private func addEvent() {
        self.addTarget(self, action: #selector(btnDidTouchDown), for: .touchDown)
        
        self.addTarget(self, action: #selector(btnDidTouchUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(btnDidTouchUp), for: .touchUpInside)
    }
    
    @objc private func btnDidTouchDown() {
        if self.alpha != 0.9 {
            self.alpha = 0.9
        }
    }
    
    @objc private func btnDidTouchUp() {
        if self.alpha != 1 {
            self.alpha = 1
        }
    }
}
