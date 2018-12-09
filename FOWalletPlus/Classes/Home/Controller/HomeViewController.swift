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
    
    private var dataSource: [AccountAssetModel] = []
    private var editIndexPath: IndexPath = IndexPath(row: -1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        let current = WalletManager.shared.getCurrent()
        if current != nil {
            getLocalData(current!)
            getAssetsOnChain(current!)
            getAccountInfo()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func makeUI() {
        navBar?.backgroundColor = UIColor.clear
        makeUIHeader()
        makeUITableView()
    }
    
    private func getLocalData(_ current: AccountModel) {
        dataSource = CacheHelper.shared.getAssetsByAccount(current.account, hide: false)
    }
    
    private func getAssetsOnChain(_ current: AccountModel) {
        HomeHttp().getAccountAssets(current.account, misHideList: dataSource) { [weak self] (resp) in
            self?.saveDataInLocal(resp)
            self?.dataSource = resp.assets.filter({ (asset) -> Bool in
                return !asset.hide
            })
            if (self?.tableView.mj_header.isRefreshing)! {
                self?.tableView.mj_header.endRefreshing()
            }
            self?.tableView.reloadData()
        }
    }
    
    private func saveDataInLocal(_ data: AssetsRespModel) {
        DispatchQueue.global().async {
            let cache = CacheHelper.shared
            cache.saveAccountAssets(data.assets)
            cache.saveTokens(Array(data.tokens.values))
        }
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
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "TokenTableViewCell", bundle: nil), forCellReuseIdentifier: "TokenTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.mj_header = createMjHeader()
        tableView.tableHeaderView = createHeaderView()
        setValue(amount: "100000000000.0000")
    }
    
    private func getAccountInfo() {
        let current = WalletManager.shared.getCurrent()
        if current != nil {
            ClientManager.shared.getAccount(account: current!.account) { (err, info) in
                if info != nil {
                    CacheHelper.shared.saveAccountInfo(info!)
                }
            }
        }
    }
    
    private func createMjHeader() -> MJRefreshGifHeader {
        var arr: [UIImage] = []
        for i in 0...23 {
            let img = UIImage(named: "refresh_loop_\(i)")
            arr.append(img!)
        }
        let header = MJRefreshGifHeader {
            [weak self] in
            let current = WalletManager.shared.getCurrent()
            if current != nil {
                self?.getAccountInfo()
                self?.getAssetsOnChain(current!)
            } else {
                if (self?.tableView.mj_header.isRefreshing)! {
                    self?.tableView.mj_header.endRefreshing()
                }
            }
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
    
    lazy var footer: UIView = {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 40))
        let showHideToken: String = LanguageHelper.localizedString(key: "ShowHideToken")
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let size = showHideToken.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
        let btn:UIButton = UIButton(frame: CGRect(x: (kSize.width - 38 - size.width) / 2, y: 0, width: 38 + size.width, height: 40))
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.colorWithHexString(hex: "#CCCCCC").cgColor
        btn.titleLabel?.font = font
        btn.setTitleColor(UIColor.colorWithHexString(hex: "#666666"), for: .normal)
        btn.setTitle(showHideToken, for: .normal)
        btn.addTarget(self, action: #selector(addTokenDidClick), for: .touchUpInside)
        footer.addSubview(btn)
        return footer
    }()
    
    // MARK: ==== 按钮点击事件 =======
    @objc private func menuBtnDidClick(sender: MenuButton) {
        
    }
    
    @objc private func addTokenDidClick() {
        
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
    
    // MARK: ====== TableView DataSource ======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenTableViewCell") as! TokenTableViewCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        let tokenInfo = CacheHelper.shared.getOneToken(model.symbol, contract: model.contract)
        if tokenInfo == nil {
            let err = LanguageHelper.localizedString(key: "NoTokenFound")
            ZSProgressHUD.showDpromptText(err)
        } else {
            let summary = TokenSummaryViewController(left: "img|back", title: nil, right: nil)
            summary.model = model
            summary.token = tokenInfo!
            navigationController?.pushViewController(summary, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataSource.count == 0 ? 0.000000001 : 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return dataSource.count == 0 ? nil : footer
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let model = dataSource[indexPath.row]
        return model.contract != "eosio"
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let hideToken = UITableViewRowAction(style: .default, title: "hide") { [weak self] (act, indexPath) in
            let model = self?.dataSource.remove(at: indexPath.row)
            CacheHelper.shared.setAssetStatus(model!, isHide: true)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        hideToken.backgroundColor = BACKGROUND_COLOR
        return [hideToken]
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        editIndexPath = indexPath
        view.setNeedsLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if editIndexPath.row < 0 { return }
        
        let cell = tableView.cellForRow(at: editIndexPath)
        let sup = IOS(version: 11) ? tableView : cell!
        let swipeStr = IOS(version: 11) ? "UISwipeActionPullView" : "UITableViewCellDeleteConfirmationView"
        let actionStr = IOS(version: 11) ? "UISwipeActionStandardButton" : "_UITableViewCellActionButton"
        for subview in sup!.subviews {
            if String(describing: subview).range(of: swipeStr) != nil {
                for sub in subview.subviews {
                    if String(describing: sub).range(of: actionStr) != nil {
                        if let button = sub as? UIButton {
                            let title = button.titleLabel?.text
                            button.setTitle("", for: .normal)
                            button.setImage(UIImage(named: title!), for: .normal)
                        }
                    }
                }
            }
        }
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
                    if imageView.y != -menuHeight {
                        imageView.y = -menuHeight
                    }
                }
            }
        }
    }
}
