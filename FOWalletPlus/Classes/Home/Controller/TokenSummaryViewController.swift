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
    private var listDataSource: [TransactionHistoryModel]! = []
    private var transDataSource: [String]!
    private var lastId: Int64 = INT64_MAX
    
    @IBOutlet weak var functionMenuView: FunctionMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        makeUI()
        makeFunctionMenu()
        createDataSource()
        tableView.mj_header.beginRefreshing()
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
                    [weak self] in
                    let withDraw = WithdrawViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "ExportToken"), right: nil)
                    withDraw.model = BaseTokenModel((self?.model.symbol)!, _contract: (self?.model.contract)!)
                    self?.navigationController?.pushViewController(withDraw, animated: true)
                },
                FunctionMenuModel("exchangeToken", _title: LanguageHelper.localizedString(key: "ExchangeToken")) {
                    [weak self] in
                    let exchange = ExchangeViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "ExchangeToken"), right: nil)
                    exchange.model = self?.token!
                    self?.navigationController?.pushViewController(exchange, animated: true)
                }
            ]
        } else {
            let payStr: String = LanguageHelper.localizedString(key: "PayToken")
            let receiveStr: String = LanguageHelper.localizedString(key: "Receive")
            btns = [
                FunctionMenuModel("payToken", _title: payStr) {
                    [weak self] in
                    let pay = PayViewController(left: "img|blackBack", title: payStr, right: "img|qrScane")
                    let tokenModel = BaseTokenModel((self?.model.symbol)!, _contract: (self?.model.contract)!)
                    pay.model = tokenModel
                    self?.navigationController?.pushViewController(pay, animated: true)
                },
                FunctionMenuModel("receiveToken", _title: LanguageHelper.localizedString(key: "ReceiveToken")) {
                    [weak self] in
                    let receive = ReceiveViewController(left: "img|blackBack", title: receiveStr, right: "img|more")
                    receive.model = BaseTokenModel((self?.model.symbol)!, _contract: (self?.model.contract)!)
                    self?.navigationController?.pushViewController(receive, animated: true)
                }
            ]
            if token.isSmart {
                let exchangeText = LanguageHelper.localizedString(key: "ExchangeToken")
                let exchange = FunctionMenuModel("exchangeToken", _title: exchangeText) {
                    [weak self] in
                    let exchange = ExchangeViewController(left: "img|blackBack", title: exchangeText, right: nil)
                    exchange.model = self?.token!
                    self?.navigationController?.pushViewController(exchange, animated: true)
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
        if !lockAmount.toDecimal().isZero {
            let lock = CommenCellModel("lock", _title: LanguageHelper.localizedString(key: "LockToken"), _value: HomeUtils.fmtQuantity(lockAmount), _showArrow: true, _target: "LockTokenViewController")
            topDataSource.append(lock)
        }
        let contractWallet = HomeUtils.getQuantity(model.contractWallet)
        if model.contract != "eosio" && !contractWallet.toDecimal().isZero {
            let wallet = CommenCellModel("contractWallet", _title: LanguageHelper.localizedString(key: "ContractWallet"), _value: HomeUtils.fmtQuantity(contractWallet), _showArrow: true, _target: "ContractWalletViewController")
            topDataSource.append(wallet)
        }
        let tokenDetail = CommenCellModel("tokenDetail", _title: LanguageHelper.localizedString(key: "TokenDetail"), _value: "", _showArrow: true, _target: "TokenDetailViewController")
        topDataSource.append(tokenDetail)
    }
    
    // MARK: ======== 构建UI =============
    private func makeUI() {
        let tokenImage = TokenImage(frame: CGRect(x: (kSize.width - 40) / 2, y: statusHeight + 2, width: 40, height: 40))
        tokenImage.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: model.isSmart, _wh: 40)
        navBar?.addSubview(tokenImage)
        makeUIHeader()
        makeUITableView()
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
        tokenLabel.text = HomeUtils.autoExtendSymbol(model.symbol, contract: model.contract)
        headerView.addSubview(tokenLabel)
        sumToken = UILabel(frame: CGRect(x: tokenLabel.x, y: tokenLabel.bottom, width: tokenLabel.width, height: 42))
        sumToken.textColor = UIColor.white
        sumToken.textAlignment = .center
        headerView.addSubview(sumToken)
        tableView.tableHeaderView = headerView
        tableView.separatorColor = SEPEAT_COLOR
        setSumTokenText()
    }
    
    private func setSumTokenText() {
        let quantity = HomeUtils.getQuantity(model.quantity)
        let lock = HomeUtils.getQuantity(model.lockToken)
        let wallet = HomeUtils.getQuantity(model.contractWallet)
        let precision = HomeUtils.getTokenPrecision(quantity)
        let sum = quantity.toDecimal() + lock.toDecimal() + wallet.toDecimal()
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
        tableView.mj_footer = createMjFooter()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommonTableViewCell", bundle: nil), forCellReuseIdentifier: "CommonTableViewCell")
        tableView.register(UINib(nibName: "LockTokenHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "LockTokenHistoryTableViewCell")
        tableView.register(LockTokenHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "LockTokenHeaderFooterView")
    }
    
    private func createMjHeader() -> MJRefreshGifHeader {
        var arr: [UIImage] = []
        for i in 0...23 {
            let img = UIImage(named: "refresh_loop_\(i)")
            arr.append(img!)
        }
        let header = MJRefreshGifHeader {
            [weak self] in
            self?.headerRefresh()
        }
        header?.setImages([UIImage(named: "logo")!], for: .idle)
        header?.setImages(arr, for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        return header!
    }

    private func createMjFooter() -> MJRefreshAutoNormalFooter {
        let footer = MJRefreshAutoNormalFooter {
            [weak self] in
            if self?.lastId == 0 {
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            self?.getTransactionList(maxId: (self?.lastId)!)
        }
        return footer!
    }
    
    private func headerRefresh() {
        self.lastId = INT64_MAX
        getTransactionList(maxId: self.lastId)
    }
    
    private func getTransactionList(maxId: Int64) {
        let current = WalletManager.shared.getCurrent()!
        HomeHttp().getTransactionHistory(symbol: model.symbol, contract: model.contract, account: current.account, maxId: maxId) { [weak self] (err, resp) in
            if self?.tableView.mj_header.isRefreshing ?? false {
                self?.tableView.mj_header.endRefreshing()
            }
            if self?.tableView.mj_footer.isRefreshing ?? false {
                self?.tableView.mj_footer.endRefreshing()
            }
            if resp != nil {
                self?.lastId = resp!.lastId
                if maxId == INT64_MAX { // 第一次加载
                    self?.listDataSource = resp!.resp
                    self?.tableView.mj_footer.resetNoMoreData()
                } else {
                    if resp!.resp.count == 0 {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        return
                    }
                    self?.listDataSource.append(contentsOf: resp!.resp)
                }
                UIView.performWithoutAnimation {
                    self?.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            }
        }
    }
    
    // MARK: ========= UItableView datasource =======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return topDataSource.count
        }
        return listDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTableViewCell") as! CommonTableViewCell
            cell.model = topDataSource[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LockTokenHistoryTableViewCell") as! LockTokenHistoryTableViewCell
            cell.historyModel = listDataSource[indexPath.row]
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
        if section == 0 {
            return 0.0001
        }
        if listDataSource.count > 0 {
            return 0.0001
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        if listDataSource.count > 0 {
            return nil
        }
        let view = UIView(frame: .zero)
        let imageView = UIImageView(frame: CGRect(x: (kSize.width - 90) / 2, y: 40, width: 90, height: 90))
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "empty")
        view.addSubview(imageView)
        return view

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LockTokenHeaderFooterView") as! LockTokenHeaderFooterView
        headerView.text = LanguageHelper.localizedString(key: "TransactionRecord")
        return headerView
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
                    let err = LanguageHelper.localizedString(key: "NoAssetsFound")
                    let btn = ModalButtonModel(LanguageHelper.localizedString(key: "OK"), _titleColor: nil, _titleFont: nil, _backgroundColor: nil, _borderColor: nil) {
                        [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    let modalModel = ModalModel(false, _imageName: "error", _title: err, _message: nil, _buttons: [btn])
                    ModalViewController(modalModel).show(source: self)
                } else {
                    vc.model = tokenInfo!
                    vc.showAddButton = false
                    navigationController?.pushViewController(vc, animated: true)
                }
                return
            }
        } else {
            let detail = TransactionDetailViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "TransactionDetail"), right: "img|more")
            let m = listDataSource[indexPath.row]
            let detailModel = TransactionDetailModel(m.quantity, _symbol: m.symbol, _contract: m.contract, _transactionDesc: m.desc, _fromAccount: m.from_account, _toAccount: m.to_account, _memo: m.memo, _created: m.created, _trx_id: m.trx_id, _isReceive: m.isReceive, _block_num: m.block_num)
            detail.model = detailModel
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return topDataSource[indexPath.row].showArrow
        }
        return true
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
