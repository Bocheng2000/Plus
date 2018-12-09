//
//  BannerCollectionViewCell.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol BannerCollectionViewCellDelegate: NSObjectProtocol {
    @objc optional func searchDidClick()
    @objc optional func scanBtnDidClick()
}

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bannerView: SDCycleScrollView!
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchLabel: UILabel!
    
    weak var delegate: BannerCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeUI()
    }

    private func makeUI() {
        bannerView.backgroundColor = UIColor.clear
        bannerView.layer.cornerRadius = 5
        bannerView.autoScrollTimeInterval = 3
        bannerView.infiniteLoop = true
        bannerView.layer.masksToBounds = true
        searchView.layer.borderColor = BORDER_COLOR.cgColor
        searchView.layer.borderWidth = 0.5
        searchView.layer.masksToBounds = true
        searchView.layer.cornerRadius = 3
        searchLabel.isUserInteractionEnabled = true
        searchLabel.text = LanguageHelper.localizedString(key: "SearchDApp")
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(searchLabelDidClick(gest:)))
        searchLabel.addGestureRecognizer(tapGest)
    }
    
    @objc private func searchLabelDidClick(gest: UITapGestureRecognizer) {
        if gest.state == .ended {
            if delegate != nil && delegate?.responds(to: #selector(BannerCollectionViewCellDelegate.searchDidClick)) ?? false {
                delegate?.searchDidClick!()
            }
        }
    }
    
    @IBAction func scanBtnDidClick(_ sender: UIButton) {
        if delegate != nil && delegate?.responds(to: #selector(BannerCollectionViewCellDelegate.scanBtnDidClick)) ?? false {
            delegate?.scanBtnDidClick!()
        }
    }
    
}
