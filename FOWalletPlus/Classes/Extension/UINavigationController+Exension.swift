//
//  UINavigationController+Etension.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/27.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation

extension UINavigationController {
    
    open func replace(_ viewController: UIViewController, animated: Bool) {
        var controllers = self.childViewControllers
        if controllers.count > 0 {
            controllers.removeLast()
            controllers.append(viewController)
            setViewControllers(controllers, animated: animated)
        }
    }
}
