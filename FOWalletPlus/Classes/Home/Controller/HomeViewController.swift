//
//  HomeViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class HomeViewController: FatherViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    private var imageView: UIImageView!
    private var amountLabel: UILabel!
    private var menuHeight: CGFloat = 157
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }

    private func makeUI() {
        navBar?.backgroundColor = UIColor.clear
        makeUIHeader()
        makeUITableView()
    }
    
    private func makeUIHeader() {
        let rect = CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight + navHeight)
        imageView = UIImageView(frame: rect)
        imageView.image = UIImage(named: "cover")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.insertSubview(imageView, belowSubview: tableView)
    }
    
    private func makeUITableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UINib(nibName: "TokenTableViewCell", bundle: nil), forCellReuseIdentifier: "TokenTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.mj_header = createMjHeader()
        tableView.tableHeaderView = createHeaderView()
        setValue(amount: "100000000000.0000")
    }
    
    private func createMjHeader() -> MJRefreshGifHeader {
        var arr: [UIImage] = []
        for i in 0...23 {
            let img = UIImage(named: "refresh_loop_\(i)")
            arr.append(img!)
        }
        let header = MJRefreshGifHeader {
            [weak self] in
            self?.findDataOnChain()
        }
        header?.setImages([UIImage(named: "logo")!], for: .idle)
        header?.setImages(arr, for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        return header!
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 130))
        let padding: CGFloat = 10
        amountLabel = UILabel(frame: CGRect(x: padding * 2, y: 0, width: kSize.width - padding * 4, height: 38))
        amountLabel.textColor = UIColor.white
        amountLabel.textAlignment = .center
        headerView.addSubview(amountLabel)
        
        let w = (kSize.width - padding * 2) / 4
        let menus: [[String: String]] = [
            ["img": "transfer", "title": LanguageHelper.localizedString(key: "Transfer")],
            ["img": "transfer", "title": LanguageHelper.localizedString(key: "Receive")],
            ["img": "transfer", "title": LanguageHelper.localizedString(key: "Vote")],
            ["img": "transfer", "title": LanguageHelper.localizedString(key: "Resource")]
        ]
        for (index, dict) in menus.enumerated() {
            let btn = MenuButton(frame: CGRect(x: padding + CGFloat(index) * w, y: amountLabel.bottom + 15, width: w, height: 70))
            btn.setImage(UIImage(named: dict["img"]!), for: .normal)
            btn.setTitle(dict["title"], for: .normal)
            btn.resize()
            btn.tag = index
                btn.addTarget(self, action: #selector(menuBtnDidClick(sender:)), for: .touchUpInside)
            headerView.addSubview(btn)
        }
        return headerView
    }
    
    // MARK: ==== 按钮点击事件 =======
    @objc private func menuBtnDidClick(sender: MenuButton) {
        
    }
    
    private func setValue(amount: String) {
        let value = "\(amount) FO"
        let attr = NSMutableAttributedString(string: value)
        attr.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ], range: NSRange(location: value.count - 2, length: 2))
        let fontSize = HomeUtils.getTextSize(value)
        attr.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            ], range: NSRange(location: 0, length: value.count - 2))
        amountLabel.attributedText = attr
    }
    
    // MARK: ====== toLoadNetData =========
    private func findDataOnChain() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (t) in
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    // MARK: ====== TableView DataSource ======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell") as! TokenTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: ====== TableView Delegate =======
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y > -kSize.height / 2 {
            if y < 0 {
                let scale = -y / 100 + 1
                imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                if !imageView.transform.isIdentity {
                    imageView.transform = CGAffineTransform.identity
                }
                if y <= menuHeight {
                    imageView.y = -y
                } else {
                    imageView.y = -menuHeight
                }
            }
        }
    }
}
