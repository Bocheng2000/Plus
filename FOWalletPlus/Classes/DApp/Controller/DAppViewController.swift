//
//  DAppViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class DAppViewController: FatherViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, SDCycleScrollViewDelegate, BannerCollectionViewCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSoruce: [[DAppModel]]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        createDs()
        findNewestDapps()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "DAppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DAppCollectionViewCell")
        collectionView.register(UINib(nibName: "DAppCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "DAppCollectionReusableView")
        collectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        collectionView.register(UINib(nibName: "CollectionFooterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionFooterCollectionReusableView")
        collectionView.backgroundColor = BACKGROUND_COLOR
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.mj_header = createMjHeader()
    }
    
    private func createMjHeader() -> MJRefreshGifHeader {
        var arr: [UIImage] = []
        for i in 0...23 {
            let img = UIImage(named: "refresh_loop_\(i)")
            arr.append(img!)
        }
        let header = MJRefreshGifHeader {
            [weak self] in
            self?.findNewestDapps()
        }
        header?.setImages([UIImage(named: "logo")!], for: .idle)
        header?.setImages(arr, for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        return header!
    }
    
    private func createDs() {
        let current = WalletManager.shared.getCurrent()
        var section1: [DAppModel] = []
        if current != nil {
            section1 = CacheHelper.shared.myDappList(owner: current!.account, pageSize: 9)
        }
        let dappBrowser = DAppModel()
        dappBrowser.id = -1
        dappBrowser.name = LanguageHelper.localizedString(key: "DAppBrowser")
        dappBrowser.img = "dappBrowser"
        section1.insert(dappBrowser, at: 0)
        
        let redPacket = DAppModel()
        redPacket.id = -1
        redPacket.name = LanguageHelper.localizedString(key: "RedPacket")
        redPacket.img = "redPacket"
        
        let api = DAppModel()
        api.id = -1
        api.name = LanguageHelper.localizedString(key: "API")
        api.img = "api"
        
        let resource = DAppModel()
        resource.id = -1
        resource.name = LanguageHelper.localizedString(key: "ResourceManager")
        resource.img = "resourceManager"
        
        let submit = DAppModel()
        submit.id = -1
        submit.name = LanguageHelper.localizedString(key: "SubmitDApp")
        submit.img = "submitDApp"
        dataSoruce = [
            [DAppModel()],
            section1,
            [redPacket, api, resource, submit],
            CacheHelper.shared.getSavedDApps(pageSize: 5)
        ]
    }
    
    private func findNewestDapps() {
        DAppHttp().getDAppList(maxId: INT64_MAX, pageSize: 5) { [weak self] (err, resp) in
            if self?.collectionView.mj_header.isRefreshing ?? false {
                self?.collectionView.mj_header.endRefreshing()
            }
            if resp != nil {
                CacheHelper.shared.saveDApps(resp!)
                self?.dataSoruce[3] = resp!
                self?.collectionView.reloadSections(IndexSet(integer: 3))
            }
        }
    }
    
    // MARK: ========== UICollection DataSource ===========
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSoruce.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSoruce[section].count
    }
    
    // MARK: ========== UICollection Delegate ===========
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
            let dappBanner: String!
            let language = LanguageHelper.getUserLanguage()
            switch language {
                case "zh-Hans":
                    fallthrough
                case "zh-Hant":
                    dappBanner = "banner_zh"
                    break
                default:
                    dappBanner = "banner_en"
                    break
            }
            cell.bannerView.localizationImageNamesGroup = [dappBanner]
            cell.delegate = self
            cell.bannerView.delegate = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DAppCollectionViewCell", for: indexPath) as! DAppCollectionViewCell
        cell.model = dataSoruce[indexPath.section][indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                return UICollectionReusableView(frame: .zero)
            }
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DAppCollectionReusableView", for: indexPath) as! DAppCollectionReusableView
            if indexPath.section == 1 {
                header.label.text = LanguageHelper.localizedString(key: "LastUsedDApps")
                header.moreBtn.isHidden = false
            } else if indexPath.section == 2 {
                header.label.text = LanguageHelper.localizedString(key: "OfficialDApps")
                header.moreBtn.isHidden = true
            } else if indexPath.section == 3 {
                header.label.text = LanguageHelper.localizedString(key: "NewestDApp")
                header.moreBtn.isHidden = false
            }
            return header
        }
        // CollectionFooterCollectionReusableView
        if kind == UICollectionElementKindSectionFooter {
            if indexPath.section == 3 {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionFooterCollectionReusableView", for: indexPath)
            }
        }
        return UICollectionReusableView(frame: .zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return .zero
        }
        return CGSize(width: kSize.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 3 {
            return CGSize(width: kSize.width, height: 50)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print(indexPath.section, indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    // MARK: ========== UICollection Layout ===========
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: kSize.width, height: 54 + floor(145 / 345 * kSize.width))
        }
        let wh = (kSize.width - 90) / 5
        return CGSize(width: wh, height: wh + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        }
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    // MARK: ===== BannerCollectionViewCellDelegate ====
    func searchDidClick() {
        print("123")
    }
    
    func scanBtnDidClick() {
        print("scan")
    }
}
