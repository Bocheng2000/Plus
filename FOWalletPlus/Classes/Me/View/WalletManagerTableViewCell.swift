//
//  WalletManagerTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/2.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WalletManagerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: CopyButton!
    
    @IBOutlet weak var currentLabel: UILabel!
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    open var model: AccountListViewModel! {
        didSet {
            nameLabel.frame = model.accountFrame
            nameLabel.setTitle(model.model.account, for: .normal)
            if model.isActive {
                currentLabel.isHidden = false
                currentLabel.frame = model.activeFrame
                currentLabel.text = LanguageHelper.localizedString(key: "CurrentWallet")
            } else {
                currentLabel.isHidden = true
            }
            publicKeyLabel.frame = model.pubKeyFrame
            publicKeyLabel.text = model.model.pubKey
            quantityLabel.frame = model.sumFrame
            quantityLabel.text = model.model.sum
            symbolLabel.frame = model.symbolFrame
            symbolLabel.text = "FO"
        }
    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += 10
            newFrame.size.width -= 20
            super.frame = newFrame
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func makeUI() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.colorWithHexString(hex: "#000000").cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
        currentLabel.layer.cornerRadius = 3
        currentLabel.layer.masksToBounds = true
    }
}
