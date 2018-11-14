//
//  SelectAccountViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class SelectAccountViewController: FatherViewController, UITableViewDelegate, UITableViewDataSource {

    open var model: BackModel!
    open var accounts: [String]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var importBtn: BaseButton!
    private var dataSource: [WhichModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        makeUI()
        createDataSource()
    }

    private func makeUI() {
        tableView.backgroundColor = BACKGROUND_COLOR
        tableView.separatorColor = SEPEAT_COLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SelectAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectAccountTableViewCell")
        
        importBtn.layer.cornerRadius = 4
        importBtn.layer.masksToBounds = true
        importBtn.isUserInteractionEnabled = false
        importBtn.setTitle(LanguageHelper.localizedString(key: "Import"), for: .normal)
    }
    
    private func createDataSource() {
        dataSource = accounts.map({ (account) -> WhichModel in
            return WhichModel(account, _type: UITableViewCellAccessoryType.none)
        })
    }
    
    // MARK: ========== UITableView DataSource And Delegate =======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAccountTableViewCell") as! SelectAccountTableViewCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        if model.type == UITableViewCellAccessoryType.none {
            model.type = UITableViewCellAccessoryType.checkmark
        } else {
            model.type = UITableViewCellAccessoryType.none
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        checkImportBtnIdOk()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    private func checkImportBtnIdOk() {
        var ok = false
        for i in 0...(dataSource.count - 1) {
            if dataSource[i].type == UITableViewCellAccessoryType.checkmark {
                ok = true
                break
            }
        }
        if ok {
            if !importBtn.isUserInteractionEnabled {
                importBtn.isUserInteractionEnabled = true
                importBtn.backgroundColor = BUTTON_COLOR
            }
        } else {
            if importBtn.isUserInteractionEnabled {
                importBtn.isUserInteractionEnabled = false
                importBtn.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    @IBAction func importBtnDidClick(_ sender: BaseButton) {
        var selectedAccount: [String] = []
        dataSource.forEach { (m) in
            if m.type == UITableViewCellAccessoryType.checkmark {
                selectedAccount.append(m.title)
            }
        }
        let manager: WalletManager = WalletManager.shared
        manager.create(selectedAccount, pubKey: model.pubKey, priKey: model.priKey, password: model.password, prompt: model.prompt)
        manager.setCurrent(pubKey: model.pubKey, account: selectedAccount[0])
        let importSuccess = LanguageHelper.localizedString(key: "ImportSuccess")
        let button = ModalButtonModel(LanguageHelper.localizedString(key: "Confirm"), _titleColor: UIColor.white, _titleFont: UIFont(name: medium, size: 14), _backgroundColor: BUTTON_COLOR, _borderColor: BUTTON_COLOR) {
            ChangeRootVC().changeRootViewController(window: UIApplication.shared.keyWindow!)
        }
        let modalModel: ModalModel = ModalModel(false, _imageName: nil, _title: importSuccess, _message: nil, _buttons: [button])
        ModalViewController(modalModel).show(source: self)
    }
}
