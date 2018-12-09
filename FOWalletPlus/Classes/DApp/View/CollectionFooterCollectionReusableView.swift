//
//  CollectionFooterCollectionReusableView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CollectionFooterCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "--- END ---"
    }
}
