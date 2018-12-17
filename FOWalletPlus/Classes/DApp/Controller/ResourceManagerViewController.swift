//
//  ResourceManagerViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ResourceManagerViewController: FatherViewController, UIScrollViewDelegate {

    private var lineView: UIView!
    private var cpu: CpuViewController!
    private var height: CGFloat = kSize.height - navHeight - safeBottom
    private var net: NetViewController?
    private var ram: RamViewController?
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        makeUIHeader()
        scrollView.backgroundColor = BACKGROUND_COLOR
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: kSize.width * 3, height: height)
        setUpChildren()
    }
    
    private func makeUIHeader() {
        let container = UIView(frame: CGRect(x: (kSize.width - 180) / 2, y: 0, width: 180, height: 44))
        container.addSubview(makeButton(index: 0, titleKey: "Cpu"))
        container.addSubview(makeButton(index: 1, titleKey: "Net"))
        container.addSubview(makeButton(index: 2, titleKey: "Ram"))
        lineView = UIView(frame: CGRect(x: 0, y: statusHeight + 35, width: 40, height: 2))
        lineView.backgroundColor = FONT_COLOR
        container.addSubview(lineView)
        navBar?.addSubview(container)
    }
    
    // MARK: ====== 顶部菜单按钮 ========
    private func makeButton(index: CGFloat, titleKey: String) -> UIButton {
        let btnW: CGFloat = 40
        let btn = UIButton(frame: CGRect(x: (btnW + 30) * index, y: statusHeight + 7, width: btnW, height: 25))
        btn.setTitle(LanguageHelper.localizedString(key: titleKey), for: .normal)
        btn.setTitleColor(FONT_COLOR, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        btn.tag = Int(index)
        btn.addTarget(self, action: #selector(btnDidClick(sender:)), for: .touchUpInside)
        return btn
    }
    
    private func setUpChildren() {
        let cpu = CpuViewController(CGRect(x: 0, y: 0, width: kSize.width, height: height))
        scrollView.addSubview(cpu.view)
        addChildViewController(cpu)
    }
    
    @objc private func btnDidClick(sender: UIButton) {
        let index = CGFloat(sender.tag)
        let pageIndex = scrollView.contentOffset.x / kSize.width
        if index == pageIndex {
            return
        }
        scrollView.setContentOffset(CGPoint(x: kSize.width * index, y: 0), animated: true)
    }
    
    // MARK: ========= ScrollView Delegate ==========
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        if offsetX < 0 || offsetX > kSize.width * 2 {
            return
        }
        if offsetX > 0 && offsetX <= kSize.width {
            if net == nil {
                net = NetViewController(CGRect(x: kSize.width, y: 0, width: kSize.width, height: height))
                scrollView.addSubview(net!.view)
                addChildViewController(net!)
            }
        }
        if offsetX > kSize.width && offsetX <= kSize.width * 2 {
            if ram == nil {
                ram = RamViewController(CGRect(x: kSize.width * 2, y: 0, width: kSize.width, height: height))
                scrollView.addSubview(ram!.view)
                addChildViewController(ram!)
            }
        }
        lineView.x = offsetX * 70 / kSize.width
    }
}
