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
    var showSmart: Bool = true
    convenience init(_ _symbol: String, _contract: String, _isSmart: Bool, _wh: CGFloat?) {
        self.init()
        symbol = _symbol
        contract = _contract
        isSmart = _isSmart
        if _wh != nil {
            wh = _wh!
        }
    }
    convenience init(_ _symbol: String, _contract: String, _isSmart: Bool, _wh: CGFloat?, _showSmart: Bool?) {
        self.init()
        symbol = _symbol
        contract = _contract
        isSmart = _isSmart
        if _wh != nil {
            wh = _wh!
        }
        if _showSmart != nil {
            showSmart = _showSmart!
        }
    }
    
}

class TokenImage: UIImageView {
    lazy var smartLabel: UILabel = {
       let label = UILabel(frame: CGRect(x: width - (width / 4), y: 0, width: width / 3, height: height / 3))
        label.backgroundColor = UIColor.colorWithHexString(hex: "#1199DD")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 0.65 * (width / 3), weight: .semibold)
        label.textColor = UIColor.white
        label.text = LanguageHelper.localizedString(key: "Smart")
        label.layer.cornerRadius = 3
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
            if model.showSmart {
                if model.isSmart {
                    smartLabel.isHidden = false
                } else {
                    smartLabel.isHidden = true
                }
            } else {
                smartLabel.isHidden = true
            }
        }
    }
}
