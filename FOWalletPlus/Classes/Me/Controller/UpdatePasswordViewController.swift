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
    }

    @IBAction func doneBtnDidClick(_ sender: BaseButton) {
    }
}
