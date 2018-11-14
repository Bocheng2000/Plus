//
//  RootViewController.swift
//  kvo
//
//  Created by Sleep on 01/01/2018.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ChangeRootVC {
    func changeRootViewController(window: UIWindow) {
        let rootVc = window.rootViewController
        let root = RootViewController()
        UIView.transition(from: (rootVc?.view)!, to: root.view, duration: 0.5, options: .transitionFlipFromLeft ) { (finish) in
            if finish {
                window.rootViewController = root
            }
        }
    }
}
