//
//  ShakeButton.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/1.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ShakeButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView?.image != nil {
            imageView!.frame = CGRect.init(
                x: (self.bounds.size.width - self.imageView!.image!.size.width) / 2.0,
                y: 0,
                width: imageView!.image!.size.width,
                height: imageView!.image!.size.height)
        }
        
        if titleLabel != nil {
            let titleLabelSize = titleLabel!.text!.getTextSize(font: titleLabel!.font, lineHeight: 0, maxSize: CGSize(width: width, height: CGFloat(MAXFLOAT)))
            titleLabel!.frame = CGRect.init(
                x: (self.bounds.size.width - titleLabelSize.width) / 2.0,
                y: imageView!.frame.maxY + 7.0,
                width: titleLabelSize.width,
                height: titleLabelSize.height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        setTitleColor(UIColor.colorWithHexString(hex: "#999999"), for: .normal)
        setTitleColor(UIColor.darkGray, for: .highlighted)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    open func shakeBtn(delay: TimeInterval) {
        let top1 = CGAffineTransform.init(translationX: 0, y: 150)
        let reset = CGAffineTransform.identity
        self.transform = top1
        self.alpha = 0.3
        UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options:.curveEaseOut , animations: {
            self.transform = reset
            self.alpha = 1
        }, completion: nil)
    }
}
