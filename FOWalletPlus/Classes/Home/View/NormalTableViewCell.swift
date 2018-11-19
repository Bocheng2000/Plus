//
//  NormalTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class NormalTableViewCell: UITableViewCell {

    open var model: NormalCellModel! {
        didSet {
            textLabel?.text = model.title
            detailTextLabel?.text = model.value
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let font = UIFont.systemFont(ofSize: 14)
        textLabel?.font = font
        textLabel?.textColor = FONT_COLOR
        detailTextLabel?.font = font
        detailTextLabel?.textColor = FONT_COLOR
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
