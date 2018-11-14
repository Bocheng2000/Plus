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
    
    public func updateTimeToNow(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let d = dateFormatter.date(from: date)
        if d != nil {
            return updateTimeToNow(date: d!)
        }
        return ""
    }
    
    public func updateTimeToNow(date: Date) -> String {
        let d = date.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let reduceTime: TimeInterval = now - d
        if reduceTime < 60 {
            return NSLocalizedString("刚刚", comment: "")
        }
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins) \(NSLocalizedString("分钟前", comment: ""))"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours) \(NSLocalizedString("小时前", comment: ""))"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days) \(NSLocalizedString("天前", comment: ""))"
        }
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        return dfmatter.string(from: date)
    }
}
