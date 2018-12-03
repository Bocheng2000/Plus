//
//  AccountListViewModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/3.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AccountListViewModel: NSObject {
    var accountFrame: CGRect!
    var activeFrame: CGRect!
    var pubKeyFrame: CGRect!
    var sumFrame: CGRect!
    var symbolFrame: CGRect!
    var isActive: Bool = false
    var model: AccountListModel! {
        didSet {
            let accountSize = model.account.getTextSize(font: UIFont.systemFont(ofSize: 13, weight: .semibold), lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
            accountFrame = CGRect(x: 20, y: 20, width: accountSize.width + 24, height: accountSize.height)
            let active = LanguageHelper.localizedString(key: "CurrentWallet")
            let size = active.getTextSize(font: UIFont.systemFont(ofSize: 10), lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
            activeFrame = CGRect(x: accountFrame.maxX + 3, y: accountFrame.minY + (accountSize.height - 16) / 2, width: size.width + 10, height: 16)
            pubKeyFrame = CGRect(x: accountFrame.minX, y: accountFrame.maxY + 15, width: kSize.width - 60, height: 21)
            let quantitySize = model.sum.getTextSize(font: UIFont.systemFont(ofSize: 19, weight: .medium), lineHeight: 0, maxSize: CGSize(width: kSize.width - 60 - 35, height: CGFloat(MAXFLOAT)))
            sumFrame = CGRect(x: accountFrame.minX, y: 125 - 20 - quantitySize.height, width: quantitySize.width, height: quantitySize.height)
            symbolFrame = CGRect(x: sumFrame.maxX + 5, y: 125 - 20 - 15, width: 30, height: 14)
        }
    }
}
