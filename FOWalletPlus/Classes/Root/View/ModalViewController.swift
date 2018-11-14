//
//  ModalViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    var model: ModalModel!
    
    convenience init(_ _model: ModalModel) {
        self.init()
        model = _model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        makeUI()
    }
    
    open func show(source: UIViewController) {
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        source.present(self, animated: true, completion: nil)
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.7)
        let padding: CGFloat = 20
        var _h: CGFloat = 0
        
        let container: UIView = UIView(frame: CGRect(x: padding, y: 0, width: kSize.width - padding * 2, height: 0))
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        view.addSubview(container)
        
        if model.closeShow {
            let closeBtn = UIButton(frame: CGRect(x: container.width - 40, y: 10, width: 30, height: 30))
            closeBtn.setImage(UIImage(named: "close"), for: .normal)
            closeBtn.addTarget(self, action: #selector(closeBtnDidClick), for: .touchUpInside)
            container.addSubview(closeBtn)
        }
        
        var img: UIImage!
        if model.imageName == nil {
            img = UIImage(named: "ok")
        } else {
            img = UIImage(named: model.imageName!)
        }
        let imageView = UIImageView(frame: CGRect(x: (container.width - 60) / 2, y: 49, width: 60, height: 60))
        imageView.image = img
        container.addSubview(imageView)
        
        let w: CGFloat = container.width - padding * 2
        let titleLabel: UILabel = UILabel(frame: CGRect(x: padding, y: imageView.bottom + 11, width: w, height: 0))
        titleLabel.font = UIFont(name: semibold, size: 20)
        titleLabel.textColor = FONT_COLOR
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = model.title
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: padding, y: imageView.bottom + 11, width: w, height: titleLabel.height)
        container.addSubview(titleLabel)
        _h = titleLabel.bottom
        
        if model.message != nil {
            let messageLabel: UILabel = UILabel(frame: CGRect(x: padding, y: titleLabel.bottom + 5, width: w, height: 0))
            messageLabel.font = UIFont.systemFont(ofSize: 14)
            messageLabel.textColor = FONT_COLOR
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.text = model.message
            messageLabel.sizeToFit()
            messageLabel.frame = CGRect(x: padding, y: imageView.bottom + 11, width: w, height: messageLabel.height)
            container.addSubview(messageLabel)
            _h = messageLabel.bottom
        }
        
        let _w: CGFloat = w - CGFloat(model.buttons.count - 1) * 20
        for i in 0...(model.buttons.count - 1) {
            let m = model.buttons[i]
            let btn = BaseButton(frame: CGRect(x: CGFloat(i) * w + 20, y: _h + 20, width: _w, height: 50))
            btn.setTitle(m.title, for: .normal)
            btn.setTitleColor(m.titleColor, for: .normal)
            btn.titleLabel?.font = m.titleFont
            btn.backgroundColor = m.backgroundColor
            btn.layer.borderWidth = 1
            btn.layer.borderColor = m.borderColor.cgColor
            btn.layer.cornerRadius = 4
            btn.layer.masksToBounds = true
            btn.tag = i + 10
            btn.addTarget(self, action: #selector(buttonDidClick(sender:)), for: .touchUpInside)
            container.addSubview(btn)
        }
        
        let height: CGFloat = _h + 70 + 20
        container.frame = CGRect(x: padding, y: (kSize.height - height) / 2, width: kSize.width - padding * 2, height: height)
    }
    
    @objc private func closeBtnDidClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func buttonDidClick(sender: BaseButton) {
        closeBtnDidClick()
        let buttons = model.buttons
        let handler = buttons![sender.tag - 10].handler
        if handler != nil {
            handler!()
        }
    }
    
}
