//
//  DAppHttp.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/9.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class DAppHttp: NSObject {

    /// 构造获取DApps列表Schema
    ///
    /// - Parameter maxId: 最大的ID
    /// - Parameter pageSize: 数量
    /// - Returns: schema
    private func generateAllDapp(maxId: Int64, pageSize: Int32) -> String {
        return """
        {
            find_dapp(
                where: {
                    token: {
                        ne: ""
                    },
                    url: {
                        ne: ""
                    },
                    id: {
                        lt: \(maxId)
                    },
                }
                limit: \(pageSize),
                order: "-id"
            ){
                id
                name
                name_en
                description
                description_en
                url
                img
                token
                tags{
                    id
                    tag{
                        id
                        name
                    }
                }
            }
        }
        """
    }
    
    /// 获取DApp列表
    ///
    /// - Parameters:
    ///   - maxId: 最大ID
    ///   - pageSize: 每页个数
    ///   - success: block
    open func getDAppList(maxId: Int64, pageSize: Int32, success: @escaping (Error?, [DAppModel]?) -> Void) {
        let schema = generateAllDapp(maxId: maxId, pageSize: pageSize)
        Http.shareHttp().graphql(urlStr: "\(dappUri)/app", params: schema) { (err, resp) in
            if resp != nil {
                let data = resp!.object(forKey: "data") as! NSDictionary
                let body = data.object(forKey: "find_dapp") as! [NSDictionary]
                var response: [DAppModel] = []
                for dict: NSDictionary in body {
                    let model = DAppModel.deserialize(from: dict)
                    if model != nil {
                        model?.description_cn = dict["description"] as? String
                        response.append(model!)
                    }
                }
                DispatchQueue.main.async(execute: {
                    success(Optional.none, response)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    success(err, Optional.none)
                })
            }
        }
    }
}
