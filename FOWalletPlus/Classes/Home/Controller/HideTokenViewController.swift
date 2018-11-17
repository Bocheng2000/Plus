//
//  HideTokenViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/17.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class HideTokenViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    open var showTokenBlock: ((AccountAssetModel) -> Void)?
    
    private var dataSource: [AccountAssetModel] = []
    private var editIndexPath: IndexPath = IndexPath(row: -1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.shared.statusBarStyle = .default
        makeUI()
        createDataSource()
    }

    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        tableView.backgroundColor = UIColor.clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "TokenTableViewCell", bundle: nil), forCellReuseIdentifier: "TokenTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func createDataSource() {
        let current = WalletManager.shared.getCurrent()
        if current != nil {
            dataSource = CacheHelper.shared.getAssetsByAccount(current!.account, hide: true)
        }
    }
    
    private func setTokenShow(indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        CacheHelper.shared.setAssetStatus(model, isHide: false)
        if showTokenBlock != nil {
            showTokenBlock!(model)
        }
        dataSource.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: =========== UITableView Delegate AND Datasource =========
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000001
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let showToken = UITableViewRowAction(style: .default, title: "showToken") { [weak self] (act, indexPath) in
            self?.setTokenShow(indexPath: indexPath)
        }
        showToken.backgroundColor = BACKGROUND_COLOR
        return [showToken]
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
        for subview in sup.subviews {
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
}
