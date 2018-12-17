//
//  RamCpuPreview.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class NetCpuPreview: UIView {
    var titleLabel: UILabel!
    var priceLabel: UILabel!
    var progressView: UIView!
    var previewLabel: UILabel!
    var delegateLabel: UILabel!
    var selfDelegateLabel: UILabel!
    var delegateSumLabel: UILabel!
    var otherDelegateLabel: UILabel!
    
    /**
     * 百分比
     */
    open var progress: CGFloat! {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.progressView.width = self.progress * (self.width - 20)
            }, completion: nil)
        }
    }
    
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
        titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 22))
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        containerView.addSubview(titleLabel)
        priceLabel = UILabel(frame: CGRect(x: titleLabel.right + 10, y: titleLabel.top, width: width - 80, height: titleLabel.height))
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        priceLabel.textColor = FONT_COLOR
        priceLabel.textAlignment = .right
        containerView.addSubview(priceLabel)
        let line = UIView(frame: CGRect(x: titleLabel.x, y: titleLabel.bottom + 10, width: width - titleLabel.x * 2, height: 0.5))
        line.backgroundColor = BORDER_COLOR
        containerView.addSubview(line)
        let container = UIView(frame: CGRect(x: titleLabel.x, y: line.bottom + 10, width: line.width, height: 24))
        container.backgroundColor = UIColor.colorWithHexString(hex: "#95C9F4")
        container.layer.cornerRadius = 3
        container.clipsToBounds = true
        container.layer.masksToBounds = true
        containerView.addSubview(container)
        progressView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: container.height))
        progressView.backgroundColor = BUTTON_COLOR
        container.addSubview(progressView)
        previewLabel = UILabel(frame: container.bounds)
        previewLabel.font = UIFont.systemFont(ofSize: 12)
        previewLabel.textColor = UIColor.white
        previewLabel.textAlignment = .center
        container.addSubview(previewLabel)
        delegateLabel = UILabel(frame: CGRect(x: titleLabel.x, y: container.bottom + 10, width: titleLabel.width, height: 20))
        delegateLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        containerView.addSubview(delegateLabel)
        let w = (width - 20) / 2
        delegateSumLabel = UILabel(frame: CGRect(x: delegateLabel.x, y: delegateLabel.bottom + 3, width: w, height: 20))
        delegateSumLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        containerView.addSubview(delegateSumLabel)
        selfDelegateLabel = UILabel(frame: CGRect(x: delegateLabel.right + 10, y: delegateLabel.top + 4, width: width - delegateLabel.right - 20, height: 18))
        selfDelegateLabel.font = UIFont.systemFont(ofSize: 12)
        selfDelegateLabel.textColor = FONT_COLOR
        selfDelegateLabel.textAlignment = .right
        containerView.addSubview(selfDelegateLabel)
        otherDelegateLabel = UILabel(frame: CGRect(x: delegateSumLabel.right, y: selfDelegateLabel.bottom + 3, width: delegateSumLabel.width, height: selfDelegateLabel.height))
        otherDelegateLabel.font = UIFont.systemFont(ofSize: 12)
        otherDelegateLabel.textColor = FONT_COLOR
        otherDelegateLabel.textAlignment = .right
        containerView.addSubview(otherDelegateLabel)
    }
}
