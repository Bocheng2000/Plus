//
//  NetCpuOperateView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol NetCpuOperateViewDelegate: NSObjectProtocol {
    @objc optional func netCpuOperateView(sender: NetCpuOperateView, isDelegate: Bool)
}

class NetCpuOperateView: UIView, UITextFieldDelegate {
    
    weak var delegate: NetCpuOperateViewDelegate?
    
    var delegateBtn: UIButton!
    var unDelegateBtn: UIButton!
    var balanceLabel: UILabel!
    var titleLabel: UILabel!
    var textField: BaseTextField!
    var receiverLabel: UILabel!
    var toSelf: UIButton!
    var toOther: UIButton!
    
    private var containerView: UIView!
    var toTextField: BaseTextField!
    var segement: UISegmentedControl!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    lazy var receive: UIView = {
        let container = UIView(frame: CGRect(x: receiverLabel.x, y: receiverLabel.bottom + 10, width: width, height: 20))
        let contactBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
        contactBtn.setImage(UIImage(named: "contact"), for: .normal)
        contactBtn.setImage(UIImage(named: "contact"), for: .highlighted)
        contactBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5)
        contactBtn.setBorderLine(position: .right, number: 0.5, color: BORDER_COLOR)
        container.addSubview(contactBtn)
        
        segement = UISegmentedControl(items: [
                LanguageHelper.localizedString(key: "Lease"),
                LanguageHelper.localizedString(key: "Trans")
            ])
        segement.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        segement.selectedSegmentIndex = 0
        var frame = segement.frame
        frame.origin.x = width - 20 - frame.size.width
        frame.size.height = container.height
        segement.frame = frame
        segement.tintColor = BUTTON_COLOR
        container.addSubview(segement)
        
        toTextField = BaseTextField(frame: CGRect(x: contactBtn.right + 10, y: contactBtn.top, width: segement.x - (contactBtn.right + 10) - 10, height: contactBtn.height))
        toTextField.borderStyle = .none
        toTextField.keyboardType = .emailAddress
        toTextField.font = UIFont.systemFont(ofSize: 12)
        toTextField.placeholder = LanguageHelper.localizedString(key: "ReceiverAccount")
        container.addSubview(toTextField)
        
        return container
    }()
    
    private func makeUI() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height - 30))
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 3
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        let delegate = LanguageHelper.localizedString(key: "Delegate")
        let font = UIFont.systemFont(ofSize: 15, weight: .medium)
        let delegateSize = delegate.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
        let undelegate = LanguageHelper.localizedString(key: "UnDelegate")
        let undelegateSize = undelegate.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
        let x = width - (delegateSize.width + 26) - (undelegateSize.width + 26) - 60
        delegateBtn = setUpButton(CGRect(x: x / 2, y: 10, width: delegateSize.width + 26, height: delegateSize.height), title: delegate, font: font)
        delegateBtn.isSelected = true
        unDelegateBtn = setUpButton(CGRect(x: delegateBtn.right + 60, y: delegateBtn.top, width: undelegateSize.width + 26, height: undelegateSize.height), title: undelegate, font: font)
        containerView.addSubview(delegateBtn)
        containerView.addSubview(unDelegateBtn)
        balanceLabel = UILabel(frame: CGRect(x: 10, y: delegateBtn.bottom + 10, width: width - 20, height: 16))
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        balanceLabel.font = titleFont
        balanceLabel.textColor = FONT_COLOR
        containerView.addSubview(balanceLabel)
        let line = UIView(frame: CGRect(x: balanceLabel.x, y: balanceLabel.bottom + 10, width: balanceLabel.width, height: 0.5))
        line.backgroundColor = BORDER_COLOR
        containerView.addSubview(line)
        titleLabel = UILabel(frame: CGRect(x: balanceLabel.x, y: line.bottom + 10, width: balanceLabel.width, height: 20))
        titleLabel.font = titleFont
        titleLabel.textColor = FONT_COLOR
        containerView.addSubview(titleLabel)
        textField = BaseTextField(frame: CGRect(x: line.x, y: titleLabel.bottom + 10, width: line.width, height: 20))
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 15)
        containerView.addSubview(textField)
        
        let line2 = UIView(frame: CGRect(x: line.x, y: textField.bottom + 10, width: line.width, height: line.height))
        line2.backgroundColor = BORDER_COLOR
        containerView.addSubview(line2)
        
        let receiverFont = UIFont.systemFont(ofSize: 12)
        
        let toSelfText = LanguageHelper.localizedString(key: "Self")
        let toSelfSize = toSelfText.getTextSize(font: receiverFont, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
        
        let toOtherText = LanguageHelper.localizedString(key: "Other")
        let toOtherSize = toOtherText.getTextSize(font: receiverFont, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
        
        receiverLabel = UILabel(frame: CGRect(x: line.x, y: line2.bottom + 10, width: line2.width - (toSelfSize.width + 14) - (toOtherSize.width + 14) - 10 , height: 20))
        receiverLabel.font = titleFont
        receiverLabel.textColor = FONT_COLOR
        receiverLabel.text = LanguageHelper.localizedString(key: "Receiver")
        containerView.addSubview(receiverLabel)
        
        toSelf = setUpReceiveButton(CGRect(x: receiverLabel.right, y: receiverLabel.top, width: toSelfSize.width + 14, height: receiverLabel.height), title: toSelfText, font: receiverFont)
        toSelf.isSelected = true
        containerView.addSubview(toSelf)
        
        toOther = setUpReceiveButton(CGRect(x: toSelf.right + 10, y: toSelf.top, width: toOtherSize.width + 14, height: toOtherSize.height), title: toOtherText, font: receiverFont)
        containerView.addSubview(toOther)
    }
    
    @objc private func delegateOrNotDidClick(sender: UIButton) {
        if sender.isSelected {
            return
        }
        sender.isSelected = true
        if sender == delegateBtn {
            unDelegateBtn.isSelected = false
        } else {
            delegateBtn.isSelected = false
        }
        if delegate != nil && delegate?.responds(to: #selector(NetCpuOperateViewDelegate.netCpuOperateView(sender:isDelegate:))) ?? false {
            delegate?.netCpuOperateView!(sender: self, isDelegate: delegateBtn.isSelected)
        }
    }
    
    @objc private func toSelfOrOtherDidClick(sender: UIButton) {
        if sender.isSelected {
            return
        }
        sender.isSelected = true
        if sender == toSelf {
            toOther.isSelected = false
            toOtherDidClick(show: false)
        } else {
            toSelf.isSelected = false
            toOtherDidClick(show: true)
        }
    }
    
    private func toOtherDidClick(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.2, animations: {
                UIView.animate(withDuration: 0.2) {
                    self.containerView.height = self.containerView.height + 30
                }
            }) { (finish) in
                self.containerView.addSubview(self.receive)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.containerView.height = self.containerView.height - 30
            }) { (finish) in
                self.receive.removeFromSuperview()
            }
        }
    }
    
    private func setUpButton(_ frame: CGRect, title: String, font: UIFont) -> UIButton {
        let button = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.setTitleColor(FONT_COLOR, for: .normal)
        button.setImage(UIImage(named: "unselect"), for: .normal)
        button.setImage(UIImage(named: "select"), for: .selected)
        button.titleLabel?.font = font
        button.addTarget(self, action: #selector(delegateOrNotDidClick(sender:)), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        return button
    }
    
    private func setUpReceiveButton(_ frame: CGRect, title: String, font: UIFont) -> UIButton {
        let button = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.setTitleColor(FONT_COLOR, for: .normal)
        button.setImage(UIImage(named: "unselect24"), for: .normal)
        button.setImage(UIImage(named: "select24"), for: .selected)
        button.titleLabel?.font = font
        button.addTarget(self, action: #selector(toSelfOrOtherDidClick(sender:)), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0)
        return button
    }
    
    // MARK: ======== UITextField Delegate ==========
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let value = (textField.text ?? "") + string
        let split = value.split(separator: ".")
        if split.count == 0 {
            return true
        }
        if split.count == 1 {
            return true
        }
        if split.count == 2 {
            return String(split[1]).count <= 4
        }
        return false
    }
}
