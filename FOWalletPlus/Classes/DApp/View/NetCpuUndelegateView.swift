//
//  RamCpuUndelegateView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class NetCpuUndelegateView: UIView {
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func makeUI() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        let containerView = UIView(frame: bounds)
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 3
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: width - 20, height: 22))
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = FONT_COLOR
        containerView.addSubview(titleLabel)
        
        let line = UIView(frame: CGRect(x: titleLabel.x, y: titleLabel.bottom + 10, width: width - titleLabel.x * 2, height: 0.5))
        line.backgroundColor = BORDER_COLOR
        containerView.addSubview(line)
        
        detailLabel = UILabel(frame: CGRect(x: line.x, y: line.bottom + 10, width: line.width, height: 16))
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = FONT_COLOR
        containerView.addSubview(detailLabel)
    }
}
