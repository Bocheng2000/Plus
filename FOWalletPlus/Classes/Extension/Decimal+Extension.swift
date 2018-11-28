//
//  Float+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/16.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation

extension Decimal {
    public func toFixed(_ precision: Int) -> String {
        let fmt = NumberFormatter()
        fmt.alwaysShowsDecimalSeparator = true
        fmt.roundingMode = .ceiling
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = precision
        return fmt.string(from: self as NSNumber)!
    }
}
