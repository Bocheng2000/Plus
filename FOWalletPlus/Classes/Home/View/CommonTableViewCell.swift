//
//  CommonTableViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/18.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CommonTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    open var model: CommenCellModel! {
        didSet {
            icon.image = UIImage(named: model.icon)
            let titleSize = model.title.getTextSize(font: titleLabel.font, lineHeight: 0, maxSize: CGSize(width: 100, height: CGFloat(MAXFLOAT)))
            titleLabel.frame = CGRect(x: 64, y: 0, width: titleSize.width, height: height)
            titleLabel.text = model.title
            valueLabel.frame = CGRect(x: titleLabel.right + 10, y: 0, width: kSize.width - titleLabel.right - 10 - 26, height: height)
            valueLabel.text = model.value
            arrowImageView.isHidden = !model.showArrow
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        arrowImageView.image = UIImage(named: "forword")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
