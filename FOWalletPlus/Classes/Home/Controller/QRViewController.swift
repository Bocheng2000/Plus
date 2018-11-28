//
//  QRViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {

    var model: QRModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        makeUI()
    }

    convenience init(_ _model: QRModel) {
        self.init()
        model = _model
    }
    
    open func show(source: UIViewController) {
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        source.present(self, animated: true, completion: nil)
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.5)
        let padding: CGFloat = 20
        let container: UIView = UIView(frame: CGRect(x: padding, y: 0, width: kSize.width - padding * 2, height: 0))
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        
        let closeBtn = UIButton(frame: CGRect(x: container.width - 40, y: 10, width: 30, height: 30))
        closeBtn.setImage(UIImage(named: "close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnDidClick), for: .touchUpInside)
        container.addSubview(closeBtn)
        
        let mask = UIView(frame: CGRect(x: (container.width - model.wh - 20) / 2, y: 68, width: model.wh + 20, height: model.wh + 20))
        mask.layer.borderWidth = 1
        mask.layer.borderColor = UIColor.colorWithHexString(hex: "#CCCCCC").cgColor
        mask.layer.cornerRadius = 4
        mask.layer.masksToBounds = true
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: model.wh, height: model.wh))
        imageView.image = HomeUtils.generateQRCode(model.value, size: CGSize(width: model.wh, height: model.wh), color: model.color)
        mask.addSubview(imageView)
        container.addSubview(mask)
        
        let tipLabel = UILabel(frame: CGRect(x: padding, y: mask.bottom + 20, width: container.width - padding * 2, height: 0))
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        tipLabel.textColor = FONT_COLOR
        let size = model.tip.getTextSize(font: tipLabel.font, lineHeight: 0, maxSize: CGSize(width: tipLabel.width, height: CGFloat(MAXFLOAT)))
        tipLabel.height = size.height
        tipLabel.text = model.tip
        let h = tipLabel.bottom + padding
        
        container.addSubview(tipLabel)
        container.frame = CGRect(x: padding, y: (kSize.height - h) / 2, width: kSize.width - padding * 2, height: h)
        view.addSubview(container)
    }
    
    @objc private func closeBtnDidClick() {
        self.dismiss(animated: true, completion: nil)
    }
}
