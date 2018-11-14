//
//  ChangeLanguageHelper.swift
//  Messenger
//
//  Created by Sleep on 2018/7/6.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation

class LanguageHelper: NSObject {
    private static var bundle: Bundle = Bundle.main
    private static var kLanguage: String = "kUserLanguage"
    private static var currentLanguage: String = ""
    
    private override init() {
        super.init()
    }
    
    
    /// 返回错误描述的key
    open class func errorDescription() -> String {
        return isZHCN() ? "ed_zh" : "ed_en"
    }
    
    //MARK: ===== 是否是中文环境 ========
    /// 是否是中文环境
    ///
    /// - Returns: Bool 值
    open class func isZHCN () -> Bool {
        if currentLanguage == "" {
            let def = UserDefaults.standard
            var value = def.string(forKey: kLanguage)
            if value == nil {
                let preferredLanguages = Locale.preferredLanguages
                value = preferredLanguages[0]
            }
            currentLanguage = value!
        }
        return currentLanguage.hasPrefix("zh")
    }
    
    //MARK: ===== 初始化用户的语言环境 ========
    /// 初始化用户的语言环境
    open class func initUserLanguage() {
        let def = UserDefaults.standard
        var value = def.string(forKey: kLanguage)
        if value == nil {
            let preferredLanguages = Locale.preferredLanguages
            value = preferredLanguages[0]
            if (value?.hasPrefix("en"))! {
                value = "en"
            } else if (value?.hasPrefix("zh"))! {
                value = "zh-Hans"
            } else {
                value = "en"
            }
            def.set(value, forKey: kLanguage)
            def.synchronize()
        }
        currentLanguage = value!
        var path = Bundle.main.path(forResource: value, ofType: "lproj")
        if path == nil {
            path = Bundle.main.path(forResource: "en", ofType: "lproj")
        }
        bundle = Bundle.init(path: path!)!
    }

    //MARK: ======= 设置用户的语言环境 =======
    /// 设置用户的语言环境
    ///
    /// - Parameter language: 语言: en zh-Hans ..
    open class func setUserLanguage(language: String) {
        let def = UserDefaults.standard
        if def.string(forKey: kLanguage) == language {
            return
        }
        currentLanguage = language
        def.set(language, forKey: kLanguage)
        def.synchronize()
        var path = Bundle.main.path(forResource: language, ofType: "lproj")
        if path == nil {
            path = Bundle.main.path(forResource: "en", ofType: "lproj")
        }
        bundle = Bundle.init(path: path!)!
    }

    
    /// 获取当前的语言名称
    ///
    /// - Returns: value
    open class func getUserLanguageName() -> String {
        switch currentLanguage {
        case "en":
            return "English"
        case "zh-Hans":
            return "简体中文"
        case "zh-Hant":
            return "繁体中文"
        default:
            return "English"
        }
    }
    
    
    /// 获取当前的语言
    ///
    /// - Returns: value
    open class func getUserLanguage() -> String {
        return currentLanguage
    }
    
    //MARK: ======== 根据key获取本地化的值 ======
    /// 根据key获取本地化的值
    ///
    /// - Parameter key: key
    /// - Returns: value
    open class func localizedString(key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }
}
