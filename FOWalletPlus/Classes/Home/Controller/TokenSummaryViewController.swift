//
//  TokenSummaryViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/18.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenSummaryViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {

    open var model: AccountAssetModel!
    open var token: TokenSummary!
    @IBOutlet weak var tableView: UITableView!
    private var bjView: UIView!
    private var menuHeight: CGFloat = 87
    private var tokenLabel: UILabel!
    private var sumToken: UILabel!
    private var topDataSource: [CommenCellModel]! = []
    private var transDataSource: [String]!
    
    @IBOutlet weak var functionMenuView: FunctionMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        makeUI()
        makeFunctionMenu()
        createDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func makeFunctionMenu() {
        var btns: [FunctionMenuModel] = []
        if token.contract == "eosio" && token.symbol == "EOS" {
            btns = [
                FunctionMenuModel("export", _title: LanguageHelper.localizedString(key: "ExportToken")) {
                    
                },
                FunctionMenuModel("exchangeToken", _title: LanguageHelper.localizedString(key: "ExchangeToken")) {
                    
                }
            ]
        } else {
            let payStr: String = LanguageHelper.localizedString(key: "PayToken")
            btns = [
                FunctionMenuModel("payToken", _title: payStr) {
                    [weak self] in
                    let pay = PayViewController(left: "img|blackBack", title: payStr, right: "img|qrScane")
                    let tokenModel = BaseTokenModel((self?.model.symbol)!, _contract: (self?.model.contract)!)
                    pay.model = tokenModel
                    self?.navigationController?.pushViewController(pay, animated: true)
                },
                FunctionMenuModel("receiveToken", _title: LanguageHelper.localizedString(key: "ReceiveToken")) {
                    
                }
            ]
            if token.isSmart {
                let exchange = FunctionMenuModel("exchangeToken", _title: LanguageHelper.localizedString(key: "ExchangeToken")) {
                    
                }
                btns.append(exchange)
            }
        }
        functionMenuView.models = btns
    }
    
    private func createDataSource() {
        let available = CommenCellModel("available", _title: LanguageHelper.localizedString(key: "AvailableBalance"), _value: HomeUtils.fmtQuantity(HomeUtils.getQuantity(model.quantity)), _showArrow: false, _target: nil)
        topDataSource.append(available)
        let lockAmount = HomeUtils.getQuantity(model.lockToken)
        if model.contract != "eosio" && lockAmount.toFloat() != 0 {
            let lock = CommenCellModel("lock", _title: LanguageHelper.localizedString(key: "LockToken"), _value: HomeUtils.fmtQuantity(lockAmount), _showArrow: true, _target: "LockTokenViewController")
            topDataSource.append(lock)
        }
        let contractWallet = HomeUtils.getQuantity(model.contractWallet)
        if contractWallet.toFloat() != 0 {
            let wallet = CommenCellModel("contractWallet", _title: LanguageHelper.localizedString(key: "ContractWallet"), _value: HomeUtils.fmtQuantity(contractWallet), _showArrow: true, _target: "ContractWalletViewController")
            topDataSource.append(wallet)
        }
        let tokenDetail = CommenCellModel("tokenDetail", _title: LanguageHelper.localizedString(key: "TokenDetail"), _value: "", _showArrow: true, _target: "TokenDetailViewController")
        topDataSource.append(tokenDetail)
    }
    
    private func makeUI() {
        let tokenImage = TokenImage(frame: CGRect(x: (kSize.width - 40) / 2, y: statusHeight + 2, width: 40, height: 40))
        tokenImage.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: model.isSmart, _wh: 40)
        navBar?.addSubview(tokenImage)
        makeUIHeader()
        makeUITableView()
    }
    
    private func makeUIHeader() {
        let headerColor: UIColor = themeColor
        bjView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight + navHeight))
        bjView.backgroundColor = headerColor
        view.insertSubview(bjView, belowSubview: tableView)
        navBar?.backgroundColor = UIColor.clear
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: menuHeight))
        headerView.backgroundColor = headerColor
        tokenLabel = UILabel(frame: CGRect(x: 10, y: 12, width: kSize.width - 20, height: 25))
        tokenLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tokenLabel.textColor = UIColor.white
        tokenLabel.textAlignment = .center
        if model.contract == "eosio" {
            tokenLabel.text = model.symbol
        } else {
            tokenLabel.text = HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)
        }
        headerView.addSubview(tokenLabel)
        sumToken = UILabel(frame: CGRect(x: tokenLabel.x, y: tokenLabel.bottom, width: tokenLabel.width, height: 42))
        sumToken.textColor = UIColor.white
        sumToken.textAlignment = .center
        headerView.addSubview(sumToken)
        tableView.tableHeaderView = headerView
        setSumTokenText()
    }
    
    private func setSumTokenText() {
        let quantity = HomeUtils.getQuantity(model.quantity)
        let lock = HomeUtils.getQuantity(model.lockToken)
        let wallet = HomeUtils.getQuantity(model.contractWallet)
        let precision = HomeUtils.getTokenPrecision(quantity)
        let sum = quantity.toFloat() + lock.toFloat() + wallet.toFloat()
        let value = HomeUtils.fmtQuantity(sum.toFixed(precision))
        let attr = NSMutableAttributedString(string: value)
        let fontSize = HomeUtils.getTextSize(value)
        attr.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            ], range: NSRange(location: 0, length: value.count))
        sumToken.attributedText = attr
    }
    
    private func makeUITableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorInset = .zero
        tableView.separatorColor = SEPEAT_COLOR
        tableView.mj_header = createMjHeader()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommonTableViewCell", bundle: nil), forCellReuseIdentifier: "CommonTableViewCell")
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
    }
    
    private func createMjHeader() -> MJRefreshGifHeader {
        var arr: [UIImage] = []
        for i in 0...23 {
            let img = UIImage(named: "refresh_loop_\(i)")
            arr.append(img!)
        }
        let header = MJRefreshGifHeader {
            [weak self] in
            self?.tableView.mj_header.endRefreshing()
        }
        header?.setImages([UIImage(named: "logo")!], for: .idle)
        header?.setImages(arr, for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        return header!
    }

    // MARK: ========= UItableView datasource =======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return topDataSource.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTableViewCell") as! CommonTableViewCell
            cell.model = topDataSource[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.00000001
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let cellModel = topDataSource[indexPath.row]
            if cellModel.target == "LockTokenViewController" {
                let vc = LockTokenViewController(left: "img|back", title: nil, right: nil)
                vc.model = model
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            if cellModel.target == "ContractWalletViewController" {
                let vc = ContractWalletViewController(left: "img|back", title: nil, right: nil)
                vc.model = model
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            if cellModel.target == "TokenDetailViewController" {
                let vc = TokenDetailViewController(left: "img|back", title: nil, right: "img|qr")
                let tokenInfo = CacheHelper.shared.getOneToken(model.symbol, contract: model.contract)
                if tokenInfo == nil {
                    let err = LanguageHelper.localizedString(key: "NoTokenFound")
                    let noticeBar = NoticeBar(title: err, defaultType: .error)
                    noticeBar.show(duration: 1, completed: nil)
                } else {
                    vc.model = tokenInfo!
                    vc.showAddButton = false
                    navigationController?.pushViewController(vc, animated: true)
                }
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return topDataSource[indexPath.row].showArrow
        }
        return false
    }
    
    // MARK: ========= UITableView delegate =========
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y > -kSize.height / 2 {
            if y < 0 {
                let scale = -y / 100 + 1
                bjView.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                if !bjView.transform.isIdentity {
                    bjView.transform = CGAffineTransform.identity
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
