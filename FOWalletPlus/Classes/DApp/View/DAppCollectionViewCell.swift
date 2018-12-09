//
//  DAppCollectionViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class DAppCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    open var model: DAppModel! {
        didSet {
            if model.id == -1 {
                imageView.image = UIImage(named: model.img)
                titleLabel.text = model.name
            } else {
                let urlStr = "\(dappUri)/fileProc/\(model.img!).t360x360.png"
                imageView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage(named: "holder"))
                titleLabel.text = getDAppName()
            }
        }
    }
    
    private func getDAppName() -> String {
        let language = LanguageHelper.getUserLanguage()
        switch language {
        case "zh-Hans":
            fallthrough
        case "zh-Hant":
            if model.name.count > 0 {
                return model.name
            }
            return model.name_en
        default:
            if model.name_en.count > 0 {
                return model.name_en
            }
            return model.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeUI()
    }
    
    private func makeUI() {
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = BORDER_COLOR.cgColor
    }

}
