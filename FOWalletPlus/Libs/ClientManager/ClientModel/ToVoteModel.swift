//
//  ToVoteModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToVoteModel: PkStringModel {
    var voter: String!
    var proxy: String = ""
    var producers: [String] = []
    convenience init(_ _voter: String, _proxy: String?, _producers: [String]) {
        self.init()
        voter = _voter
        if _proxy != nil {
            proxy = _proxy!
        }
        producers = _producers
    }
}

class VoteModel: FatherModel {
    var voter: String!
    var proxy: String!
    var producers: [String] = []
    convenience init(_ _voter: String, _proxy: String, _producers: [String]) {
        self.init()
        voter = _voter
        proxy = _proxy
        producers = _producers
    }
}
