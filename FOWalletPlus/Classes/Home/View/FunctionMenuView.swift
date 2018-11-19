//
//  FunctionMenuView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class FunctionMenuView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setBorderLine(position: .top, number: 0.5, color: BORDER_COLOR)
        backgroundColor = UIColor.white
    }
    
    open var models: [FunctionMenuModel]! {
        didSet {
            makeUI()
        }
    }
    
    private func makeUI() {
        for v in subviews {
            v.removeFromSuperview()
        }
        let w = kSize.width / CGFloat(models.count)
        for i in 0...(models.count - 1) {
            let model = models[i]
            let btn = UIButton(frame: CGRect(x: CGFloat(i) * w, y: 0, width: w, height: height))
            btn.setTitleColor(FONT_COLOR, for: .normal)
            btn.addTarget(self, action: #selector(btnDidClick(sender:)), for: .touchUpInside)
            btn.setImage(UIImage(named: model.icon), for: .normal)
            btn.setTitle(model.title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            let imageWh: CGFloat = 18
            btn.imageEdgeInsets = UIEdgeInsetsMake((height - imageWh) / 2, -imageWh + 7, (height - imageWh) / 2, 0)
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            btn.tag = i
            addSubview(btn)
        }
    }
    
    @objc private func btnDidClick(sender: UIButton) {
        models[sender.tag].handler()
    }
}
