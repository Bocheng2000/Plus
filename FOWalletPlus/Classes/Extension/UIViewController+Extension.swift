//
//  Tabbar.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showRedPointAtIndex(index: Int) -> Void {
        let tabbarVc:UITabBarController = getTabbar()!
        createPointAtIndex(index:index, tabbarVc: tabbarVc)
    }
    
    func hideRedPointAtIndex(index: Int) -> Void {
        let tabbarVc:UITabBarController = getTabbar()!
        hidePointAt(index: index, tabbarVc:tabbarVc)
    }
    
    func hideAll() -> Void {
        removeAllPoint()
    }
    
    //MARK:获取tabbar
    private func getTabbar() -> UITabBarController? {
        let rootVc = UIApplication.shared.keyWindow?.rootViewController
        if(rootVc!.isKind(of:UITabBarController.superclass()!)){
            return rootVc as? UITabBarController
        }
        return nil
    }
    
    //MARK:创建小红点
    private func createPointAtIndex(index: Int, tabbarVc: UITabBarController) -> Void {
        hidePointAt(index: index, tabbarVc: tabbarVc)
        let tabbar: UITabBar = tabbarVc.tabBar
        let childCount:Int = tabbarVc.childViewControllers.count
        let _w:CGFloat = kSize.width / CGFloat(childCount + 1)
        let point = UIView(frame: CGRect(x: _w * CGFloat(2 * index + 1) / 2 + 13, y: 5, width: 0, height: 0))
        point.tag = 888 + index
        point.backgroundColor = UIColor.red
        point.layer.cornerRadius = 4
        point.layer.masksToBounds = true
        tabbar.addSubview(point)
        UIView.animate(withDuration: 0.5) {
            point.frame = CGRect(x: _w * CGFloat(2 * index + 1) / 2 + 13, y: 5, width: 8, height: 8)
        }
    }
    
    //MARK:移出指定位置小红点
    private func hidePointAt(index:Int, tabbarVc:UITabBarController) -> Void {
        let tabbar: UITabBar = tabbarVc.tabBar
        for subView:UIView in tabbar.subviews {
            if(subView.tag == 888 + index){
                UIView.animate(withDuration: 0.5, animations: {
                    let rect = subView.frame
                    subView.frame = CGRect(x: rect.minX, y: rect.minY, width: 0, height: 0)
                }, completion: { (finish:Bool) in
                    if(finish){
                        subView.removeFromSuperview()
                    }
                })
                break
            }
        }
    }
    //MARK:移出小红点
    private func removeAllPoint() -> Void {
        let tabbarVc:UITabBarController = getTabbar()!
        let tabbar = tabbarVc.tabBar
        let childCount = tabbarVc.childViewControllers.count
        for subView:UIView in tabbar.subviews {
            if(subView.tag >= 888 && subView.tag <= 888 + childCount){
                UIView.animate(withDuration: 0.5, animations: {
                    let rect = subView.frame
                    subView.frame = CGRect(x: rect.minX, y: rect.minY, width: 0, height: 0)
                }, completion: { (finish:Bool) in
                    if(finish){
                        subView.removeFromSuperview()
                    }
                })
            }
        }
    }
}
