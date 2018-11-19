//
//  PayViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class PayViewController: FatherViewController {

    open var model: BaseTokenModel!
    
    open var payInfo: PayModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var payButton: BaseButton!
    
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
        
    }
}
