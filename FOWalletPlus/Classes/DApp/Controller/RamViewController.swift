//
//  RamViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class RamViewController: UIViewController {

    private var frame: CGRect!
    convenience init(_ frame: CGRect) {
        self.init()
        self.frame = frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        makeUI()
    }
    
    private func makeUI() {
        view.frame = frame
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
