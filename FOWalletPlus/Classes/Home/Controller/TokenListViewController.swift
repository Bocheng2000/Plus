//
//  TokenListViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/29.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenListViewController: FatherViewController, UITableViewDataSource, UITableViewDelegate {

    open var takeTokenBlock: ((AccountAssetModel) -> Void)?
    
    private var dataSource: [AccountAssetModel]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        findMyAsset()
        makeUI()
    }
    
    private func findMyAsset() {
        let current = WalletManager.shared.getCurrent()!
        dataSource = CacheHelper.shared.getAssetsByAccount(current.account, hide: false)
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5
            , color: BORDER_COLOR)
        tableView.backgroundColor = BACKGROUND_COLOR
        tableView.separatorColor = SEPEAT_COLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TokenListTableViewCell", bundle: nil), forCellReuseIdentifier: "TokenListTableViewCell")
    }

    // MARK: ====== UITableView Delegate And DataSource =====
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenListTableViewCell") as! TokenListTableViewCell
        cell.model = dataSource[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if takeTokenBlock != nil {
            let model = dataSource[indexPath.section]
            takeTokenBlock!(model)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
}
