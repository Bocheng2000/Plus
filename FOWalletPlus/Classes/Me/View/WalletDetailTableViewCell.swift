//
//  WalletDetailTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/3.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WalletDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var valueButton: CopyButton!
    
    open var model: WalletDetailCellModel! {
        didSet {
            keyLabel.text = model.title
            if model.value == nil {
                keyLabel.frame = CGRect(x: 10, y: 0, width: kSize.width - 20 - 20, height: 48)
                valueButton.isHidden = true
            } else {
                keyLabel.frame = CGRect(x: 10, y: 0, width: 80, height: height)
                valueButton.frame = CGRect(x: keyLabel.right + 8, y: 0, width: kSize.width - 20 - keyLabel.right - 8, height: 48)
                valueButton.isHidden = false
                valueButton.setTitle(model.value, for: .normal)
            }
            accessoryType = model.type
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
