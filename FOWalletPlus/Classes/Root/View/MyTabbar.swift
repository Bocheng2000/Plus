//
//  MyTabbar.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/2.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class MyTabbar: UITabBar {
    var itemFrames = [CGRect]()
    var tabBarItems = [UIView]()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if itemFrames.isEmpty, let UITabBarButtonClass = NSClassFromString("UITabBarButton") as? NSObject.Type {
            tabBarItems = subviews.filter({$0.isKind(of: UITabBarButtonClass)})
            tabBarItems.forEach({itemFrames.append($0.frame)})
        }
        
        if !itemFrames.isEmpty, !tabBarItems.isEmpty, itemFrames.count == items?.count {
            tabBarItems.enumerated().forEach({$0.element.frame = itemFrames[$0.offset]})
        }
    }
}
