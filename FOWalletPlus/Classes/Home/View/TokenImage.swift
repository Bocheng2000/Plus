//
//  TokenImage.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/17.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenImageModel: NSObject {
    var symbol: String!
    var contract: String!
    var isSmart: Bool!
    var wh: CGFloat! = 60
    convenience init(_ _symbol: String, _contract: String, _isSmart: Bool, _wh: CGFloat?) {
        self.init()
        symbol = _symbol
        contract = _contract
        isSmart = _isSmart
        if _wh != nil {
            wh = _wh!
        }
    }
}

class TokenImage: UIImageView {
    lazy var smartLabel: UILabel = {
       let label = UILabel(frame: CGRect(x: width - 15, y: 0, width: 20, height: 20))
        label.backgroundColor = UIColor.colorWithHexString(hex: "#1199DD")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor.white
        label.text = LanguageHelper.localizedString(key: "Smart")
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(smartLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(smartLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open var model: TokenImageModel! {
        didSet {
            if model.contract == "eosio" {
                if model.symbol == "FO" {
                    image = UIImage(named: "fo")
                } else {
                    image = UIImage(named: "eos")
                }
            } else {
                let data = model.contract.data(using: .utf8)!
                let generator = IconGenerator(size: model.wh * scale, hash: data)
                image = UIImage(cgImage: generator.render()!)
            }
            if model.isSmart {
                smartLabel.isHidden = false
            } else {
                smartLabel.isHidden = true
            }
        }
    }
}
