//
//  MeViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class MeViewController: FatherViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: [[CommenCellModel]] = []
    
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
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommonTableViewCell", bundle: nil), forCellReuseIdentifier: "CommonTableViewCell")
    }
    
    // MARK: ================= 构建数据源 =================
    private func createDs() {
        let walletManager = CommenCellModel("wallet", _title: LanguageHelper.localizedString(key: "WalletManager"), _value: "", _showArrow: true, _target: nil)
        let help = CommenCellModel("help", _title: LanguageHelper.localizedString(key: "HelpCenter"), _value: "", _showArrow: true, _target: nil)
        let about = CommenCellModel("about", _title: LanguageHelper.localizedString(key: "AboutUS"), _value: "", _showArrow: true, _target: nil, _showDot: true)
        let system = CommenCellModel("system", _title: LanguageHelper.localizedString(key: "SystemSetting"), _value: "", _showArrow: true, _target: nil)
        let safeTest = CommenCellModel("safe", _title: LanguageHelper.localizedString(key: "SafeTest"), _value: "", _showArrow: true, _target: nil)
        dataSource = [
            [walletManager, system],
            [safeTest],
            [help, about]
        ]
    }
    
    // MARK: ========== UITableView DataSource And Delegate =======
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTableViewCell") as! CommonTableViewCell
        cell.model = dataSource[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let walletManager = WalletManagerViewController(left: "img|blackBack", title: model.title, right: nil)
                navigationController?.pushViewController(walletManager, animated: true)
            } else {
                
            }
        }
    }
}
