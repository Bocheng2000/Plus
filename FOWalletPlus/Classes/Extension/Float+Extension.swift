//
//  Float+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/16.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation

extension Float {
    
    public func toFixed(_ precision: Int) -> String {
        return String.init(format: "%.\(precision)f", self)
    }
}
