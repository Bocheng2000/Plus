//
//  TokenTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {
    @IBOutlet weak var tokenImage: TokenImage!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBOutlet weak var contractLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var moneyLabel: UILabel!
    
    open var model: AccountAssetModel! {
        didSet {
            let w = kSize.width - 20
            let h: CGFloat = 80
            tokenImage.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: model.isSmart, _wh: nil)
            if model.contract == "eosio" {
                let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                let size = model.symbol.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: 125, height: CGFloat(MAXFLOAT)))
                tokenLabel.frame = CGRect(x: 80, y: 0, width: size.width, height: h)
                tokenLabel.font = font
                contractLabel.isHidden = true
            } else {
                let font = UIFont.systemFont(ofSize: 18)
                let size = model.symbol.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: 125, height: CGFloat(MAXFLOAT)))
                tokenLabel.frame = CGRect(x: 80, y: 17, width: size.width, height: 25)
                tokenLabel.font = font
                contractLabel.isHidden = false
                contractLabel.frame = .zero
                contractLabel.text = "@\(model.contract!)"
                contractLabel.sizeToFit()
                contractLabel.frame = CGRect(x: tokenLabel.x, y: tokenLabel.bottom, width: contractLabel.width, height: contractLabel.height)
            }
            tokenLabel.text = model.symbol
            let quantity = HomeUtils.getQuantity(model.quantity)
            let lock = HomeUtils.getQuantity(model.lockToken)
            let wallet = HomeUtils.getQuantity(model.contractWallet)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let all = quantity.toDecimal() + lock.toDecimal() + wallet.toDecimal()
            quantityLabel.frame = CGRect(x: tokenLabel.right + 5, y: 17, width: w - 15 - tokenLabel.right, height: 25)
            quantityLabel.text = all.toFixed(precision)
            moneyLabel.frame = CGRect(x: contractLabel.right + 5, y: quantityLabel.bottom, width: w - 15 - contractLabel.right, height: 20)
            moneyLabel.text = "≈ 0.00"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeUI()
    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += 10
            newFrame.size.width -= 20
            newFrame.size.height -= 20
            super.frame = newFrame
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            contentView.backgroundColor = UIColor.colorWithHexString(hex: "#D9D9D9")
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
    
    private func makeUI() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.colorWithHexString(hex: "#816AAF").cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 15
        contractLabel.font = UIFont.systemFont(ofSize: 14)
        contractLabel.textColor = UIColor.colorWithHexString(hex: "#999999")
        let color = UIColor.colorWithHexString(hex: "#3092FB")
        quantityLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        quantityLabel.textColor = color
        moneyLabel.textColor = color
        moneyLabel.font = UIFont.systemFont(ofSize: 14)
        layer.zPosition = 1
    }
}
