//
//  DAppModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class DAppModel: FatherModel {
    var id: Int64!
    var name: String!
    var name_en: String!
    var description_cn: String!
    var description_en: String!
    var url: String!
    var img: String!
    var token: String!
    var tags: [DAppTagsModel]!
}

class DAppTagsModel: FatherModel {
    var id: Int64!
    var tag: DAppTagModel!
}

class DAppTagModel: FatherModel {
    var id: Int64!
    var name: String!
}
