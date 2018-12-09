//
//  WalletManagerViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/2.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WalletManagerViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var footerView: FunctionMenuView!
    private var dataSource: [AccountListViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        createDs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = SEPEAT_COLOR
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WalletManagerTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletManagerTableViewCell")
    }
    
    private func createDs() {
        let list = WalletManager.shared.walletList()
        let current = WalletManager.shared.getCurrent()!
        dataSource = list.map { (model) -> AccountListViewModel in
            let m = AccountListViewModel()
            m.model = model
            m.isActive = current.account == model.account
            return m
        }
    }
    
    // MARK: ======= UITableView Delegate And DataSource ========
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletManagerTableViewCell") as! WalletManagerTableViewCell
        cell.model = dataSource[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section].model
        let walletDetail = WalletDetailViewController(left: "img|back", title: model?.account, right: nil)
        walletDetail.model = model
        navigationController?.pushViewController(walletDetail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 15 : 0.000001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}
