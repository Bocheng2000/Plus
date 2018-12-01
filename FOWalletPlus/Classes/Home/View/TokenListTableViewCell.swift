//
//  TokenListTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/29.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenListTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImage: TokenImage!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    open var model: AccountAssetModel! {
        didSet {
            tokenImage.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: model.isSmart, _wh: 30)
            tokenLabel.text = HomeUtils.autoExtendSymbol(model.symbol, contract: model.contract)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
