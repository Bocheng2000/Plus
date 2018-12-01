//
//  ModalPanelModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/1.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ModalPanelModel: NSObject {
    var title: String?
    var top: [ItemOptModel] = []
    var bottom: [ItemOptModel] = []
}

class ItemOptModel: NSObject {
    var title: String!
    var image: UIImage!
    convenience init(_ _title: String, _image: UIImage) {
        self.init()
        title = _title
        image = _image
    }
}
