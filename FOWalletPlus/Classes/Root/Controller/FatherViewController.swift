//
//  FatherViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//


import UIKit

class FatherViewController: UIViewController {

    internal var navBar: UIView?
    
    internal var leftBtn: UIButton?
    internal var titleLabel: UILabel?
    internal var rightBtn: UIButton?
    
    private var _left: String?
    private var _title: String?
    private var _right: String?
    
    convenience init(left: String?, title: String?, right: String?) {
        self.init()
        _left = left
        _title = title
        _right = right
    }
    
    // MARK: 左侧按钮点击事件
    @objc internal func leftBtnDidClick() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc internal func rightBtnDidClick() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }
    
    private func makeUI() {
        view.backgroundColor = BACKGROUND_COLOR
        if _left == nil && _title == nil && _right == nil {
            return
        }
        navBar = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: navHeight))
        navBar?.backgroundColor = UIColor.white
        navBar?.layer.zPosition = 9
        if _left != nil {
            let array = _left?.split(separator: "|")
            leftBtn = UIButton(frame: CGRect(x: 10, y: statusHeight + 2, width: 40, height: 40))
            if array![0] == "img" {
                leftBtn?.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 29)
                let imgName = array![1]
                leftBtn?.setImage(UIImage(named: String(imgName)), for: .normal)
            } else {
                leftBtn?.contentHorizontalAlignment = .left
                let leftTitle = array![1]
                leftBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                leftBtn?.setTitleColor(FONT_COLOR, for: .normal)
                leftBtn?.setTitle(String(leftTitle), for: .normal)
            }
            leftBtn?.addTarget(self, action: #selector(leftBtnDidClick), for: .touchUpInside)
            navBar?.addSubview(leftBtn!)
        }
        if _title != nil {
            titleLabel = UILabel(frame: CGRect(x: 50, y: statusHeight + 2, width: kSize.width - 100, height: 40))
            titleLabel?.textAlignment = .center
            titleLabel?.font = UIFont(name: medium, size: 18)
            titleLabel?.text = _title
            titleLabel?.textColor = FONT_COLOR
            navBar?.addSubview(titleLabel!)
        }
        if _right != nil {
            let array = _right?.split(separator: "|")
            rightBtn = UIButton(frame: CGRect(x: kSize.width - 50, y: statusHeight + 2, width: 40, height: 40))
            if array![0] == "img" {
                rightBtn?.imageEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
                let imgName = array![1]
                rightBtn?.setImage(UIImage(named: String(imgName)), for: .normal)
            } else {
                rightBtn?.contentHorizontalAlignment = .right
                let rightTitle = array![1]
                rightBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                rightBtn?.setTitleColor(FONT_COLOR, for: .normal)
                rightBtn?.setTitle(String(rightTitle), for: .normal)
            }
            rightBtn?.addTarget(self, action: #selector(rightBtnDidClick), for: .touchUpInside)
            navBar?.addSubview(rightBtn!)
        }
        view.addSubview(navBar!)
    }

}
