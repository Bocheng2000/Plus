//
//  AuthorizeTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/12.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AuthorizeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
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
        let font = UIFont.systemFont(ofSize: 15)
        let color = UIColor.colorWithHexString(hex: "#4C4D60")
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        textLabel?.font = font
        textLabel?.textColor = color
        detailTextLabel?.font = font
        detailTextLabel?.textColor = color
    }
    
}
