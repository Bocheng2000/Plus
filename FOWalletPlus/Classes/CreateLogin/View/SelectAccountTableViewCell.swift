//
//  SelectAccountTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class SelectAccountTableViewCell: UITableViewCell {

    open var model: WhichModel! {
        didSet {
            textLabel?.text = model.title
            accessoryType = model.type
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
        textLabel?.font = UIFont.systemFont(ofSize: 18)
        textLabel?.textColor = FONT_COLOR
        tintColor = BUTTON_COLOR
    }
    
}
