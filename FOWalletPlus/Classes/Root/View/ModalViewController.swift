//
//  ModalViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    var model: ConfirmModel!
    
    convenience init(_ _model: ConfirmModel) {
        self.init()
        model = _model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        makeUI()
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.9)
    }
    
    
}
