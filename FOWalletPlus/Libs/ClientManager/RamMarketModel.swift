//
//  RamMarketModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class RamMarketModel: Codable {
    var supply: String!
    var base: RamMarketBaseModel!
    var quote: RamQuoteModel!
}

class RamMarketBaseModel: Codable {
    var balance: String!
    var weight: String!
}

class RamQuoteModel: Codable {
    var balance: String!
    var weight: String!
}
