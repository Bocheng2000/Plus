//
//  UpdatePasswordViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/3.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: FatherViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var oldPwdLabel: UILabel!
    
    @IBOutlet weak var oldInputField: BaseTextField!
    
    @IBOutlet weak var newPwsLabel: UILabel!
    
    @IBOutlet weak var newPwdTextField: BaseTextField!
    
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBOutlet weak var confirmTextField: BaseTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.backgroundColor = UIColor.clear
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        oldPwdLabel.text = LanguageHelper.localizedString(key: "OldPwd")
        newPwsLabel.text = LanguageHelper.localizedString(key: "NewPwd")
        confirmLabel.text = LanguageHelper.localizedString(key: "RepeatPwd")
    }

    @IBAction func doneBtnDidClick(_ sender: BaseButton) {
        
    }
}
