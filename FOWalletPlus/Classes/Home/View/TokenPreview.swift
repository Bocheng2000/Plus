//
//  TokenPreview.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenPreview: UIView {
    
    var titleLabel: UILabel!
    var tokenImageView: TokenImage!
    var tokenLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    private func makeUI() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: width, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.colorWithHexString(hex: "#666666")
        addSubview(titleLabel)
        tokenImageView = TokenImage(frame: CGRect(x: 0, y: titleLabel.bottom + 3, width: 30, height: 30))
        tokenImageView.contentMode = .scaleAspectFill
        addSubview(tokenImageView)
        tokenLabel = UILabel(frame: CGRect(x: tokenImageView.right + 10, y: tokenImageView.top, width: width - tokenImageView.right - 20, height: tokenImageView.height))
        tokenLabel.font = UIFont.systemFont(ofSize: 18)
        tokenLabel.textColor = FONT_COLOR
        addSubview(tokenLabel)
        setBorderLine(position: .bottom, number: 0.5, color: lineColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
