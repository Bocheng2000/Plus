//
//  TokenTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {

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
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }
    
}
