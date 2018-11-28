//
//  TokenSummary.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/16.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenSummary: NSObject, Codable {
    var max_supply: String!
    var supply: String!
    var connector_balance: String!
    var connector_weight: String!
    var issuer: String!
    var max_exchange: String!
    var reserve_connector_balance: String!
    var reserve_supply: String!
    
    enum CodingKeys : String, CodingKey {
        case max_supply = "maxSupply"
        case supply
        case connector_balance = "connectorBalance"
        case connector_weight = "connectorWeight"
        case issuer
        case max_exchange = "maxExchange"
        case reserve_connector_balance = "reserveConnectorBalance"
        case reserve_supply = "reserveSupply"
    }
    
    
    var contract: String! {
        get {
            return issuer
        }
    }
    var symbol: String! {
        get {
            return HomeUtils.getSymbol(supply)
        }
    }
    var isSmart: Bool! {
        get {
            if issuer == "eosio" {
                return symbol == "FO"
            } else {
                return connector_weight.toDecimal() != 0
            }
        }
    }
}
