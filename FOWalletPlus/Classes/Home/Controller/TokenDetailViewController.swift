//
//  TokenDetailViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/18.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TokenDetailViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: ======= Props ==============
    @IBOutlet weak var tableView: UITableView!
    open var model: TokenSummary!
    open var showAddButton: Bool = true
    private var bjView: UIView!
    private var menuHeight: CGFloat = 87
    private var tokenLabel: UILabel!
    private var sumToken: UILabel!
    private var assetModel: AccountAssetModel?
    private var dataSource: [NormalCellModel]!
    
    @IBOutlet weak var addBtnConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addButton: BaseButton!
    
    // MARK: ===== Life cycle =============
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createDs()
        findDataInLocal()
        makeUI()
        makeUIAddButton()
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func createDs() {
        let maxSupply = HomeUtils.getQuantity(model.max_supply)
        let fmtMaxSupply = HomeUtils.fmtQuantity(maxSupply)
        let maxModel = NormalCellModel(LanguageHelper.localizedString(key: "MaxSupply"), _value: fmtMaxSupply)
        dataSource = [maxModel]
        if !model.isSmart {
            let supply = HomeUtils.getQuantity(model.supply)
            let fmtSupply = HomeUtils.fmtQuantity(supply)
            let supplyModel = NormalCellModel(LanguageHelper.localizedString(key: "Supply"), _value: fmtSupply)
            dataSource.append(supplyModel)
        } else {
            let maxExchange = HomeUtils.getQuantity(model.max_exchange)
            let fmtMaxExchange = HomeUtils.fmtQuantity(maxExchange)
            let maxExchangeModel = NormalCellModel(LanguageHelper.localizedString(key: "MaxExchange"), _value: fmtMaxExchange)
            
            let reserveSupply = HomeUtils.getQuantity(model.reserve_supply)
            let fmtReserveSupply = HomeUtils.fmtQuantity(reserveSupply)
            let reserveSupplyModel = NormalCellModel(LanguageHelper.localizedString(key: "ReserveSupply"), _value: fmtReserveSupply)
            
            let connectorBalance = HomeUtils.getQuantity(model.connector_balance)
            let fmtConnectorBalance = HomeUtils.fmtQuantity(connectorBalance)
            let connectorBalanceSymbol = HomeUtils.getSymbol(model.connector_balance)
            let connectorBalanceModel = NormalCellModel(LanguageHelper.localizedString(key: "ConnectorBalance"), _value: "\(fmtConnectorBalance) \(connectorBalanceSymbol)")
            let connectorWeight = model.connector_weight.toDecimal() * Decimal(10000) / Decimal(100)
            let cwModel = NormalCellModel(LanguageHelper.localizedString(key: "ConnectorWeight"), _value: "\(connectorWeight.toFixed(2)) %")
            
            let reserveBalance = HomeUtils.getQuantity(model.reserve_connector_balance)
            let symbol = HomeUtils.getSymbol(model.reserve_connector_balance)
            let fmtReserveBalance = HomeUtils.fmtQuantity(reserveBalance)
            let reserveBalanceModel = NormalCellModel(LanguageHelper.localizedString(key: "ReserveBalance"), _value: "\(fmtReserveBalance) \(symbol)")
            dataSource.append(contentsOf: [maxExchangeModel, reserveSupplyModel, connectorBalanceModel, cwModel, reserveBalanceModel])
        }
    }
    
    private func findDataInLocal() {
        let current = WalletManager.shared.getCurrent()
        if current != nil {
            assetModel = CacheHelper.shared.getOneAsset(current!.account, symbol: model.symbol, contract: model.contract)
        }
    }
    
    private func makeUI() {
        let tokenImage = TokenImage(frame: CGRect(x: (kSize.width - 40) / 2, y: statusHeight + 2, width: 40, height: 40))
        tokenImage.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: model.isSmart, _wh: 40)
        navBar?.addSubview(tokenImage)
        makeUIHeader()
        makeUITableView()
    }

    private func makeUIAddButton() {
        if showAddButton {
            addButton.setTitleColor(UIColor.white, for: .normal)
            addButton.addTarget(self, action: #selector(addButtonDidClick), for: .touchUpInside)
            if assetModel != nil {
                addButton.isUserInteractionEnabled = false
                addButton.backgroundColor = UIColor.RGBA(r: 17, g: 153, b: 221, a: 0.2)
                addButton.setTitle(LanguageHelper.localizedString(key: "Added"), for: .normal)
            } else {
                addButton.isUserInteractionEnabled = true
                addButton.backgroundColor = BUTTON_COLOR
                addButton.setTitle(LanguageHelper.localizedString(key: "Add"), for: .normal)
            }
        } else {
            addBtnConstraint.constant = 0
            addButton.isHidden = true
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
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
        var value: String!
        if assetModel == nil {
            let quantity = HomeUtils.getQuantity(model.supply)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let zero: Decimal = Decimal(0)
            value = zero.toFixed(precision)
        } else {
            let quantity = HomeUtils.getQuantity(assetModel!.quantity)
            let lock = HomeUtils.getQuantity(assetModel!.lockToken)
            let wallet = HomeUtils.getQuantity(assetModel!.contractWallet)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let sum = quantity.toDecimal() + lock.toDecimal() + wallet.toDecimal()
            value = HomeUtils.fmtQuantity(sum.toFixed(precision))
        }
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
        tableView.register(UINib(nibName: "NormalTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalTableViewCell")
    }
    
    private func createMjHeader() -> MJRefreshGifHeader {
        var arr: [UIImage] = []
        for i in 0...23 {
            let img = UIImage(named: "refresh_loop_\(i)")
            arr.append(img!)
        }
        let header = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(getTokenByContractOnChain))
        header?.setImages([UIImage(named: "logo")!], for: .idle)
        header?.setImages(arr, for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        return header!
    }
    
    // MARK: =========== 右侧按钮点击事件 ===========
    override func rightBtnDidClick() {
        let info = TokenInfoQRModel(model.symbol, _contract: model.contract)
        let createQR = CreateQRModel("TokenDetail", _params: info.toJSONString()!)
        let qrModel = QRModel(createQR.toJSONString()!, _wh: 180, _tip: LanguageHelper.localizedString(key: "ScanWithFOWallet"), _color: nil)
        QRViewController(qrModel).show(source: self)
    }
    
    // MARK: =========== 添加通证智账户 ============
    @objc private func addButtonDidClick() {
        if assetModel == nil {
            let current = WalletManager.shared.getCurrent()!
            let quantity = HomeUtils.getQuantity(model.supply)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let zeroSymbol = HomeUtils.getSymbol(model.supply)
            let zero: Decimal = Decimal(0)
            let zeroQuantity = "\(zero.toFixed(precision)) \(zeroSymbol)"
            let assetModel = AccountAssetModel(0, _belong: current.account, _contract: model.contract, _hide: false, _quantity: zeroQuantity, _lockToken: zeroQuantity, _contractWallet: zeroQuantity, _isSmart: model.isSmart)
            CacheHelper.shared.saveAccountAssets([assetModel])
            CacheHelper.shared.saveTokens([model])
        }
        addButton.isUserInteractionEnabled = false
        addButton.backgroundColor = UIColor.RGBA(r: 17, g: 153, b: 221, a: 0.2)
        addButton.setTitle(LanguageHelper.localizedString(key: "Added"), for: .normal)
    }
    
    // MARK: =========== 获取指定的合约的通证 ============
    @objc private func getTokenByContractOnChain() {
        ClientManager.shared.getTokenByContract(model.contract) { [weak self] (err, resp) in
            if (self?.tableView.mj_header.isRefreshing)! {
                self?.tableView.mj_header.endRefreshing()
            }
            if resp != nil {
                for i in 0...((resp!.rows?.count)! - 1) {
                    let token = resp!.rows?[i]
                    if token?.symbol == self?.model.symbol {
                        self?.model = token!
                        self?.createDs()
                        self?.tableView.reloadData()
                        break
                    }
                }
            }
        }
    }
    
    // MARK: =========== TableView Deleagte AND DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NormalTableViewCell") as! NormalTableViewCell
        cell.model = dataSource[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
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
