//
//  ModalPanelViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/1.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol ModalPanelViewControllerDelegate: NSObjectProtocol {
    @objc optional func modalPanelCanceled(sender: ModalPanelViewController)
    @objc optional func modalPanelClickAt(sender: ModalPanelViewController, section: Int, row: Int)
}

class ModalPanelViewController: UIViewController {
    weak var delegate: ModalPanelViewControllerDelegate?
    open var model: ModalPanelModel!
    private var btns: [ShakeButton] = []
    private var h: CGFloat = 0
    private var mask: UIView!
    private var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }
    
    convenience init(_ _model: ModalPanelModel) {
        self.init()
        model = _model
    }
    
    open func show(source: UIViewController) {
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        source.present(self, animated: false) {
            self.animated()
        }
    }
    
    private func animated() {
        var delay: TimeInterval = 0
        var i: TimeInterval = 0
        for btn in btns {
            if i == 5 {
                delay = 0
            }
            delay += 0.05
            i += 1
            btn.shakeBtn(delay: delay)
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.mask.alpha = 1
            self.mask.height = kSize.height - self.h
            self.container.y = kSize.height - self.h
        })
    }

    private func makeUI() {
        view.backgroundColor = UIColor.clear
        mask = UIView(frame: kBounds)
        let gest = UITapGestureRecognizer(target: self, action: #selector(cancelBtnDidClick))
        mask.addGestureRecognizer(gest)
        mask.alpha = 0
        mask.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.3)
        view.addSubview(mask)
        h = 5
        container = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 0))
        container.backgroundColor = UIColor.colorWithHexString(hex: "#F6F6F6")
        view.addSubview(container)
        if model.title != nil {
            let titleLabel = UILabel(frame: CGRect(x: 20, y: h, width: kSize.width - 40, height: 20))
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = UIColor.colorWithHexString(hex: "#999999")
            titleLabel.textAlignment = .center
            titleLabel.text = model.title
            container.addSubview(titleLabel)
            h = titleLabel.bottom + 5
        }
        let btnW: CGFloat = 54
        let btnH: CGFloat = 80
        let scrollViewHeight: CGFloat = 115
        let margin: CGFloat = 18
        btns.removeAll()
        if model.top.count > 0 {
            let scrollView = createScrollView(CGRect(x: 0, y: h, width: kSize.width, height: scrollViewHeight))
            for (i, v) in model.top.enumerated() {
                let btn = ShakeButton(frame: CGRect(x: (btnW + margin) * CGFloat(i), y: (scrollViewHeight - btnH) / 2, width: btnW, height: btnH))
                btn.tag = i
                btn.setImage(v.image, for: .normal)
                btn.setTitle(v.title, for: .normal)
                btn.addTarget(self, action: #selector(section1BtnDidClick(sender:)), for: .touchUpInside)
                scrollView.addSubview(btn)
                btns.append(btn)
            }
            scrollView.contentSize = CGSize(width: (btnW + margin) * CGFloat(model.top.count), height: btnH)
            container.addSubview(scrollView)
            h = h + scrollViewHeight
        }
        if model.bottom.count > 0 {
            let line = UIView(frame: CGRect(x: 20, y: h + 5, width: kSize.width - 40, height: 0.5))
            line.backgroundColor = UIColor.colorWithHexString(hex: "#DDDDDD")
            container.addSubview(line)
            
            h = h + 5
            let scrollView = createScrollView(CGRect(x: 0, y: h, width: kSize.width, height: scrollViewHeight))
            for (i, v) in model.bottom.enumerated() {
                let btn = ShakeButton(frame: CGRect(x: (btnW + margin) * CGFloat(i), y: (scrollViewHeight - btnH) / 2, width: btnW, height: btnH))
                btn.setImage(v.image, for: .normal)
                btn.setTitle(v.title, for: .normal)
                btn.tag = i
                btn.addTarget(self, action: #selector(section2BtnDidClick(sender:)), for: .touchUpInside)
                scrollView.addSubview(btn)
                btns.append(btn)
            }
            scrollView.contentSize = CGSize(width: (btnW + margin) * CGFloat(model.bottom.count), height: btnH)
            container.addSubview(scrollView)
            h = h + scrollViewHeight
        }
        h = h + 5
        let btn = UIButton(frame: CGRect(x: 0, y: h, width: kSize.width, height: 48))
        btn.setTitle(LanguageHelper.localizedString(key: "Cancel"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(UIColor.colorWithHexString(hex: "#333333"), for: .normal)
        btn.backgroundColor = UIColor.white
        btn.addTarget(self, action: #selector(cancelBtnDidClick), for: .touchUpInside)
        container.addSubview(btn)
        h = h + 48 + safeBottom
        container.frame = CGRect(x: 0, y: kSize.height, width: kSize.width, height: h)
    }
    
    @objc private func section1BtnDidClick(sender: UIButton) {
        if delegate != nil {
            delegate?.modalPanelClickAt!(sender: self, section: 0, row: sender.tag)
        }
        hideAnimated()
    }
    
    @objc private func section2BtnDidClick(sender: UIButton) {
        if delegate != nil {
            delegate?.modalPanelClickAt!(sender: self, section: 1, row: sender.tag)
        }
        hideAnimated()
    }
    
    @objc private func cancelBtnDidClick() {
        if delegate != nil {
            delegate?.modalPanelCanceled!(sender: self)
        }
        hideAnimated()
    }
    
    private func hideAnimated() {
        UIView.animate(withDuration: 0.2, animations: {
            self.mask.alpha = 0
            self.container.y = kSize.height
        }) { (finish) in
            if finish {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func createScrollView(_ frame: CGRect) -> UIScrollView {
        let scrollView = UIScrollView(frame: frame)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20)
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
}
