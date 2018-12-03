//
//  WalletDetailViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/3.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WalletDetailViewController: FatherViewController, UITableViewDataSource, UITableViewDelegate {

    open var model: AccountListModel!
    
    @IBOutlet weak var tableView: UITableView!
    private var bjView: UIView!
    private var menuHeight: CGFloat = 97
    private var dataSource: [[WalletDetailCellModel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        createDs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func makeUI() {
        navBar?.backgroundColor = themeColor
        titleLabel?.textColor = UIColor.white
        makeHeaderView()
        makeFooterView()
        setTableView()
    }

    private func createDs() {
        let account = WalletDetailCellModel(LanguageHelper.localizedString(key: "AccountName"), _value: model.account, _type: UITableViewCellAccessoryType.none)
        let pubKey = WalletDetailCellModel(LanguageHelper.localizedString(key: "PubKey"), _value: model.pubKey, _type: UITableViewCellAccessoryType.none)
        let reset = WalletDetailCellModel(LanguageHelper.localizedString(key: "ResetPwd"), _value: nil, _type: UITableViewCellAccessoryType.disclosureIndicator)
        let exportPk = WalletDetailCellModel(LanguageHelper.localizedString(key: "ExportPK"), _value: nil, _type: UITableViewCellAccessoryType.disclosureIndicator)
        let powerManager = WalletDetailCellModel(LanguageHelper.localizedString(key: "PowerManager"), _value: nil, _type: UITableViewCellAccessoryType.disclosureIndicator)
        let whiteList = WalletDetailCellModel(LanguageHelper.localizedString(key: "WhiteList"), _value: nil, _type: UITableViewCellAccessoryType.disclosureIndicator)
        dataSource = [
            [account, pubKey],
            [reset],
            [exportPk, powerManager, whiteList]
        ]
    }
    
    private func makeHeaderView() {
        bjView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight + navHeight))
        bjView.backgroundColor = themeColor
        view.insertSubview(bjView, belowSubview: tableView)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight))
        let tokenView = TokenImage(frame: CGRect(x: (kSize.width - 40) / 2, y: 8, width: 40, height: 40))
        tokenView.model = TokenImageModel("FO", _contract: "eosio", _isSmart: true, _wh: 40)
        headerView.addSubview(tokenView)
        let sum = UILabel(frame: CGRect(x: 20, y: tokenView.bottom + 8, width: kSize.width - 40, height: 30))
        sum.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        sum.textColor = UIColor.white
        sum.textAlignment = .center
        sum.text = HomeUtils.getFullQuantity(model.sum, symbol: "FO")
        headerView.addSubview(sum)
        headerView.backgroundColor = themeColor
        tableView.tableHeaderView = headerView
    }
    
    private func makeFooterView() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 100))
        let deleteBtn = BaseButton(frame: CGRect(x: 10, y: 30, width: kSize.width - 20, height: 48))
        if WalletManager.shared.walletList().count == 1 {
            deleteBtn.backgroundColor = UIColor.RGBA(r: 251, g: 61, b: 56, a: 0.7)
            deleteBtn.isUserInteractionEnabled = false
        } else {
            deleteBtn.backgroundColor = UIColor.RGBA(r: 251, g: 61, b: 56, a: 1)
            deleteBtn.isUserInteractionEnabled = true
            deleteBtn.addTarget(self, action: #selector(deleteBtnDidClick), for: .touchUpInside)
        }
        deleteBtn.setTitle(LanguageHelper.localizedString(key: "DeleteWallet"), for: .normal)
        deleteBtn.layer.cornerRadius = 3
        deleteBtn.layer.masksToBounds = true
        deleteBtn.setTitleColor(UIColor.white, for: .normal)
        footer.addSubview(deleteBtn)
        tableView.tableFooterView = footer
    }
    
    private func setTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorColor = BORDER_COLOR
        tableView.register(UINib(nibName: "WalletDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletDetailTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: ======= 删除钱包按钮点击事件 ============
    @objc private func deleteBtnDidClick() {
        print("here")
    }
    
    // MARK: ========== UITableView Deleagte And DataSource ======
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletDetailTableViewCell") as! WalletDetailTableViewCell
        cell.model = dataSource[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 0.000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    // MARK: ========= UITableView delegate =========
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y > -kSize.height / 2 {
            if y < 0 {
                bjView.height = menuHeight + navHeight - y
            } else {
                if bjView.height != menuHeight + navHeight {
                    bjView.height = menuHeight + navHeight
                }
                if y <= menuHeight {
                    bjView.y = -y
                } else {
                    if bjView.y != -menuHeight {
                        bjView.y = -menuHeight
                    }
                }
            }
        }
    }
}
