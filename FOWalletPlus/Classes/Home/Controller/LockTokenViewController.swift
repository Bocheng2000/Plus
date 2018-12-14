//
//  LockTokenViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/18.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class LockTokenViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {

    open var model: AccountAssetModel!
    
    private var lockTokenDataSource: [AssetsModel] = []
    private var historyDataSource: [LockTokenHistoryModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    private var bjView: UIView!
    private var menuHeight: CGFloat = 87
    private var tokenLabel: UILabel!
    private var sumToken: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }

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
        tokenLabel.text = "\(HomeUtils.autoExtendSymbol(model.symbol, contract: model.contract)) \(LanguageHelper.localizedString(key: "LockToken"))"
        headerView.addSubview(tokenLabel)
        sumToken = UILabel(frame: CGRect(x: tokenLabel.x, y: tokenLabel.bottom, width: tokenLabel.width, height: 42))
        sumToken.textColor = UIColor.white
        sumToken.textAlignment = .center
        headerView.addSubview(sumToken)
        tableView.tableHeaderView = headerView
        setSumTokenText()
    }
    
    private func setSumTokenText() {
        let lock = HomeUtils.getQuantity(model.lockToken)
        let precision = HomeUtils.getTokenPrecision(lock)
        let value = lock.toDecimal().toFixed(precision)
        let attr = NSMutableAttributedString(string: value)
        let fontSize = HomeUtils.getTextSize(value)
        attr.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            ], range: NSRange(location: 0, length: value.count))
        sumToken.attributedText = attr
    }

    private func makeUITableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = SEPEAT_COLOR
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorInset = .zero
        tableView.separatorColor = SEPEAT_COLOR
        tableView.mj_header = createMjHeader()
        tableView.mj_footer = createMjFooter()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LockTokenTableViewCell", bundle: nil), forCellReuseIdentifier: "LockTokenTableViewCell")
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
            let last = self?.historyDataSource.last
            if last == nil {
                self?.tableView.mj_footer.endRefreshing()
                return
            }
            self?.findListOnchain(maxId: last!.id)
        }
        return footer!
    }
    
    private func headerRefresh() {
        findLockTokenOnChain()
        findListOnchain(maxId: INT64_MAX)
    }
    
    private func findListOnchain(maxId: Int64) {
        let current = WalletManager.shared.getCurrent()!
        HomeHttp().getLockTokenHistory(symbol: model.symbol, contract: model.contract, account: current.account, maxId: maxId) { [weak self] (ex, resp) in
            if self?.tableView.mj_header.isRefreshing ?? false {
                self?.tableView.mj_header.endRefreshing()
            }
            if self?.tableView.mj_footer.isRefreshing ?? false {
                self?.tableView.mj_footer.endRefreshing()
            }
            if resp != nil {
                if maxId == INT64_MAX { // 第一次加载
                    self?.historyDataSource = resp!
                    self?.tableView.mj_footer.resetNoMoreData()
                } else {
                    self?.historyDataSource.append(contentsOf: resp!)
                    if resp!.count < basePageSize {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                }
                UIView.performWithoutAnimation {
                    self?.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            }
        }
    }
    
    //MARK: ========= 去加载线上的锁仓通证 =============
    private func findLockTokenOnChain() {
        let current = WalletManager.shared.getCurrent()!
        HomeHttp().getLockTokenList(current.account, lowerBound: 0, list: []) { [weak self] (err, lockTokens) in
            if err == nil {
                self?.processLockTokens(lockTokens)
            }
        }
    }
    
    //MARK: ========== 处理锁仓通证 =======
    private func processLockTokens(_ lockTokens: [AssetsModel]) {
        var lockTokenDs:[AssetsModel] = []
        var all: Decimal = Decimal(0)
        for lockToken in lockTokens {
            let balance = lockToken.balance!
            let symbol = HomeUtils.getSymbol(balance.quantity)
            if symbol == model.symbol && balance.contract == model.contract {
                lockTokenDs.append(lockToken)
                all = all + HomeUtils.getQuantity(balance.quantity).toDecimal()
            }
        }
        let precisionFull = HomeUtils.getTokenPrecisionFull(model.quantity)
        model.lockToken = HomeUtils.getFullQuantity(all.toFixed(precisionFull), symbol: model.symbol)
        lockTokenDataSource = lockTokenDs
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        setSumTokenText()
    }
    
    // MARK: ========= UITableView DataSource And Deleagte ========
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return lockTokenDataSource.count
        }
        return historyDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LockTokenTableViewCell") as! LockTokenTableViewCell
            cell.model = lockTokenDataSource[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LockTokenHistoryTableViewCell") as! LockTokenHistoryTableViewCell
        cell.model = historyDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let detail = LockTokenDetailViewController(left: "img|back", title: nil, right: nil)
            detail.model = lockTokenDataSource[indexPath.row]
            detail.isSmart = model.isSmart
            navigationController?.pushViewController(detail, animated: true)
        } else {
            let detail = TransactionDetailViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "TransactionDetail"), right: "img|more")
            let model = historyDataSource[indexPath.row]
            let quantity = HomeUtils.getQuantity(model.data.quantity.quantity)
            let symbol = HomeUtils.getSymbol(model.data.quantity.quantity)
            var desc: String!
            if model.action == "exlocktrans" {
                if model.isReceive {
                    desc = LanguageHelper.localizedString(key: "ReceiveToken")
                } else {
                    desc = LanguageHelper.localizedString(key: "PayToken")
                }
            } else {
                desc = LanguageHelper.localizedString(key: "UnLockToken")
            }
            let detailModel = TransactionDetailModel(quantity, _symbol: symbol, _contract: model.data.quantity.contract, _transactionDesc: desc, _fromAccount: model.from_account, _toAccount: model.to_account, _memo: model.data.memo, _created: model.created, _trx_id: model.trx_id, _isReceive: model.isReceive, _block_num: model.block_num)
            detail.model = detailModel
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 63
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0001
        }
        if historyDataSource.count > 0 {
            return 0.0001
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        if historyDataSource.count > 0 {
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
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LockTokenHeaderFooterView") as! LockTokenHeaderFooterView
        if section == 0 {
            view.text = LanguageHelper.localizedString(key: "LockToken")
        } else {
            view.text = LanguageHelper.localizedString(key: "TransactionRecord")
        }
        return view
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
