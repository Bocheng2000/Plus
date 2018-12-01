//
//  LockTokenTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/29.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class LockTokenTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImage: TokenImage!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var lockToLabel: UILabel!
    
    open var model: AssetsModel! {
        didSet {
            let balance = model.balance!
            let symbol = HomeUtils.getSymbol(balance.quantity)
            tokenImage.model = TokenImageModel(symbol, _contract: balance.contract, _isSmart: false, _wh: 24)
            let text = HomeUtils.autoExtendSymbol(symbol, contract: balance.contract)
            let size = text.getTextSize(font: tokenLabel.font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
            tokenLabel.frame = CGRect(x: 54, y: 10, width: size.width, height: 24)
            tokenLabel.text = text
            quantityLabel.frame = CGRect(x: tokenLabel.right + 10, y: tokenLabel.y, width: kSize.width - tokenLabel.right - 10 - 20, height: tokenLabel.height)
            quantityLabel.text = HomeUtils.getQuantity(balance.quantity)
            let lockTo = "\(model.lock_timestamp!).000Z".utcTime2Local(format: nil)
            lockToLabel.text = "\(LanguageHelper.localizedString(key: "LockTo")) \(lockTo)"
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
