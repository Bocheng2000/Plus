//
//  Date+Extension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation

extension Date {
    //MARK: ===== 时间格式化 ======
    public func format(formatter: String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formatter ?? "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter.string(from: self)
    }
    
    public func utcFormatter(formatter: String?) -> String {
        let local = NSTimeZone.local
        let offset = local.secondsFromGMT()
        let ts = TimeInterval(Int(self.timeIntervalSince1970) - offset)
        return Date.init(timeIntervalSince1970: ts).format(formatter: formatter)
    }
    
    public static func now() -> Int {
        return Int(floor(Date().timeIntervalSince1970 * 1000))
    }
}
