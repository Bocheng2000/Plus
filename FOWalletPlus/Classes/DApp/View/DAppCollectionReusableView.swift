//
//  DAppCollectionReusableView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class DAppCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var tinerView: UIView!
    
    @IBOutlet weak var label: UILabel!
    
    
    @IBOutlet weak var moreBtn: MoreButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func makeUI() {
        contentView.backgroundColor = BACKGROUND_COLOR
        tinerView.backgroundColor = themeColor
        label.textColor = FONT_COLOR
        moreBtn.titleLabel?.textAlignment = .right
        moreBtn.setTitle(LanguageHelper.localizedString(key: "More"), for: .normal)
        moreBtn.setTitleColor(themeColor, for: .normal)
    }
    
    @IBAction func moreBtnDidClick(_ sender: UIButton) {
        
    }
}
