//
//  ConstKeys.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/12.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation
import UIKit

let FONT_COLOR: UIColor = UIColor.colorWithHexString(hex: "#333333")
let NAVBAR_COLOR: UIColor = UIColor.white
let BORDER_COLOR: UIColor = UIColor.colorWithHexString(hex: "#DDDDDD")
let BACKGROUND_COLOR: UIColor = UIColor.white
let ERROR_COLOR: UIColor = UIColor.colorWithHexString(hex: "#FF9900")
let BUTTON_COLOR: UIColor = UIColor.colorWithHexString(hex: "#1199DD")
let TINT_COLOR: UIColor = UIColor.colorWithHexString(hex: "#7066B0")
let SEPEAT_COLOR: UIColor = UIColor.colorWithHexString(hex: "#DEDEDE")
let themeColor: UIColor = UIColor.colorWithHexString(hex: "#6965B3")

let kBounds = UIScreen.main.bounds
let scale = UIScreen.main.scale
let kSize = kBounds.size
let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets
let safeBottom = safeAreaInsets?.bottom ?? 0
let safeTop = safeAreaInsets?.top ?? 0
let isX = CGFloat(safeBottom) > 0
let statusHeight:CGFloat = safeTop == 0 ? 20 : safeTop
let tabbarHeight:CGFloat = safeBottom + 49
let navHeight:CGFloat = statusHeight + 44

// MARK: ===== EndPoint =======
var defaultHttpEndPoint = "http://to-rpc.fibos.io:8870"
let tunnel = "https://tunnel.fibos.io/1.0/app/token/create"
let salt = "kQkAjnFj8vI="

// MARK: ===== ConstKey ======
let pageSize: Int32 = 100

// MARK: ===== Cache ======
let cacheDB = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)/cache.db"

// MARK: ====== REGEX =========
let createAccountReg = "^[a-z1-5]{12}$"
let passwordRegex = "^.{8,}"

// MARK: ======= IOS Version =======
func IOS(version: Int) -> Bool {
    return ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: version, minorVersion: 0, patchVersion: 0))
}

func getEndPoint() -> String {
    return defaultHttpEndPoint
}

func setEndPoint(value: String) {
    defaultHttpEndPoint = value
}
