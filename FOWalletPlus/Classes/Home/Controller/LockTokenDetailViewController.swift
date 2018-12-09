//
//  LockTokenDetailViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/1.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class LockTokenDetailViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {

    open var model: AssetsModel!
    open var isSmart: Bool!
    
    
    private var bjView: UIView!
    private var menuHeight: CGFloat = 87
    private var tokenLabel: UILabel!
    private var sumToken: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var functionMenuView: FunctionMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        setFuncMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func makeUI() {
        let tokenImage = TokenImage(frame: CGRect(x: (kSize.width - 40) / 2, y: statusHeight + 2, width: 40, height: 40))
        tokenImage.model = TokenImageModel(model.balance.symbol, _contract: model.balance.contract, _isSmart: isSmart, _wh: 40)
        navBar?.addSubview(tokenImage)
        makeUIHeader()
        makeUITableView()
        setSumTokenText()
    }
    
    private func setFuncMenu() {
        let transfer = FunctionMenuModel("unlockTransfer", _title: LanguageHelper.localizedString(key: "Transfer")) {
            [weak self] in
            let lockPay = LockPayViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "Transfer"), right: nil)
            lockPay.model = self?.model
            self?.navigationController?.pushViewController(lockPay, animated: true)
        }
        let unlock = FunctionMenuModel("unlock", _title: LanguageHelper.localizedString(key: "UnLockToken")) {
            [weak self] in
            self?.unLockTokenDidClick()
        }
        functionMenuView.models = [transfer, unlock]
    }
    
    private func makeUIHeader() {
        bjView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight + navHeight))
        bjView.backgroundColor = themeColor
        view.insertSubview(bjView, belowSubview: tableView)
        navBar?.backgroundColor = UIColor.clear
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight))
        headerView.backgroundColor = themeColor
        tokenLabel = UILabel(frame: CGRect(x: 10, y: 12, width: kSize.width - 20, height: 25))
        tokenLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tokenLabel.textColor = UIColor.white
        tokenLabel.textAlignment = .center
        tokenLabel.text = HomeUtils.autoExtendSymbol(model.balance.symbol, contract: model.balance.contract)
        headerView.addSubview(tokenLabel)
        sumToken = UILabel(frame: CGRect(x: tokenLabel.x, y: tokenLabel.bottom, width: tokenLabel.width, height: 42))
        sumToken.textColor = UIColor.white
        sumToken.textAlignment = .center
        headerView.addSubview(sumToken)
        tableView.separatorColor = SEPEAT_COLOR
        tableView.tableHeaderView = headerView
    }

    private func makeUITableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorInset = .zero
        tableView.separatorColor = SEPEAT_COLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NormalTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalTableViewCell")
    }
    
    private func setSumTokenText() {
        let precision = HomeUtils.getTokenPrecisionFull(model.balance.quantity)
        let sum = HomeUtils.getQuantity(model.balance.quantity).toDecimal()
        let value = sum.toFixed(precision)
        let attr = NSMutableAttributedString(string: value)
        let fontSize = HomeUtils.getTextSize(value)
        attr.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            ], range: NSRange(location: 0, length: value.count))
        sumToken.attributedText = attr
    }
    
    private func unLockTokenDidClick() {
        let lockAtTs = "\(model.lock_timestamp!).000Z".utcTime2LocalDate().timeIntervalSince1970
        let now = Date.now()
        if Int(lockAtTs) * 1000 > now {
            let error = LanguageHelper.localizedString(key: "UnReachUnLockTs")
            ZSProgressHUD.showDpromptText(error)
            return
        }
        let unlock = UnLockTokenViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "UnLockToken"), right: nil)
        unlock.model = model
        navigationController?.pushViewController(unlock, animated: true)
    }
    
    // MARK: ========== UITableView DataSource And Delegate =========
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NormalTableViewCell") as! NormalTableViewCell
        let date = (model.lock_timestamp! + ".000Z").utcTime2LocalDate()
        let toUnlock = Date.init(timeIntervalSince1970: date.timeIntervalSince1970 + 1).format(formatter: "yyyy/MM/dd HH:mm")
        cell.model = NormalCellModel(LanguageHelper.localizedString(key: "CanUnLockTime"), _value: toUnlock)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
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
