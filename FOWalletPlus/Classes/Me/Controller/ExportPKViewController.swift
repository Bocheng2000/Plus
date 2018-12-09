//
//  ExportPKViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/6.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ExportPKViewController: FatherViewController {

    open var pkString: String!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var copyBtn: BaseButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = UIColor.clear
        let container = UIView(frame: CGRect(x: 0, y: 10, width: kSize.width, height: 0))
        container.backgroundColor = UIColor.white
        scrollView.addSubview(container)
        
        let text = LanguageHelper.localizedString(key: "SafeWarning")
        let font = UIFont.systemFont(ofSize: 15)
        let size = text.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: kSize.width - 46, height: CGFloat(MAXFLOAT)))
        
        let tipLabel = UILabel(frame: CGRect(x: 20, y: 20, width: kSize.width - 40, height: size.height + 6))
        tipLabel.text = text
        tipLabel.font = font
        let warningColor = UIColor.colorWithHexString(hex: "#BE303A")
        tipLabel.textColor = warningColor
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        tipLabel.layer.borderColor = warningColor.cgColor
        tipLabel.layer.borderWidth = 1
        tipLabel.layer.cornerRadius = 3
        tipLabel.layer.masksToBounds = true
        tipLabel.backgroundColor = UIColor.colorWithHexString(hex: "#FBEFEF")
        container.addSubview(tipLabel)
        
        let pkLabel = UILabel(frame: .zero)
        let pkFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        pkLabel.font = pkFont
        let fmtPk = fmtPrikey()
        let pkSize = fmtPk.getTextSize(font: pkFont, lineHeight: 0, maxSize: CGSize(width: kSize.width - 46, height: CGFloat(MAXFLOAT)))
        pkLabel.text = fmtPk
        pkLabel.frame = CGRect(x: 20, y: tipLabel.bottom + 20, width: kSize.width - 40, height: pkSize.height + 6)
        pkLabel.numberOfLines = 0
        pkLabel.textColor = UIColor.colorWithHexString(hex: "#2B393C")
        pkLabel.backgroundColor = UIColor.colorWithHexString(hex: "#F2F3F5")
        pkLabel.layer.cornerRadius = 3
        pkLabel.layer.masksToBounds = true
        pkLabel.textAlignment = .center
        container.addSubview(pkLabel)
        container.height = pkLabel.bottom + 20
        copyBtn.backgroundColor = BUTTON_COLOR
        copyBtn.setTitle(LanguageHelper.localizedString(key: "CopyPkString"), for: .normal)
    }
    
    // MARK: ====== 格式化私钥 =======
    private func fmtPrikey() -> String {
        let size = Int(ceil(Float(pkString.count) / 4.0))
        var fmtedPriKey: [String] = []
        let startIndex = pkString.startIndex
        for i in 0...(size - 1) {
            let start = pkString.index(startIndex, offsetBy: i * 4)
            var endIndex = (i + 1) * 4
            if endIndex > pkString.count {
                endIndex = pkString.count
            }
            let end = pkString.index(startIndex, offsetBy: endIndex)
            fmtedPriKey.append("\(pkString[start..<end])")
        }
        return fmtedPriKey.joined(separator: " ")
    }
    
    @IBAction func copyBtnDidClick(_ sender: UIButton) {
        UIPasteboard.general.string = pkString
        let success = LanguageHelper.localizedString(key: "CopySuccess")
        ZSProgressHUD.showDpromptText(success)
    }
}
