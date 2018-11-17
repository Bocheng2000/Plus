//
//  AssetsRespModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/17.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AssetsRespModel: NSObject {
    var assets: [AccountAssetModel]!
    var tokens: [String: TokenSummary]!
    convenience init(_ _assets: [AccountAssetModel], _tokens: [String: TokenSummary]) {
        self.init()
        assets = _assets
        tokens = _tokens
    }
}
