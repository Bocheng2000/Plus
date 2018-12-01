//
//  Http.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

typealias successBlock = (String) -> Void
typealias failBlock = (String) -> Void
typealias progressBlock = (CGFloat) -> Void

class Http: NSObject, URLSessionDataDelegate {
    static var httpErrorCode: Int = 9999
    static var httpErrorDomain = "HttpError"
    
    private static var http:Http = Http()
    private static var kTimeoutInterval:TimeInterval = 30 //链接超时
    private var success: successBlock?
    private var fail: failBlock?
    private var progress: progressBlock?
    
    
    /**
     * 单利
     */
    class func shareHttp() -> Http {
        return http
    }
    
    private override init() {
        
    }
    
    
    /// Post 请求
    ///
    /// - Parameters:
    ///   - urlStr: url
    ///   - params: 参数
    ///   - success: block
    open func post(urlStr:String, params:Any?, success:@escaping (Error?, NSDictionary?) -> Void) {
        let url = URL(string: urlStr)
        let body = try!JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
        var request = URLRequest(url: url!)
        request.timeoutInterval = Http.kTimeoutInterval
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared //单例
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil { //出错
                success(error, Optional.none)
            }else {
                guard let res = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else {
                    let ex = NSError(domain: Http.httpErrorDomain, code: Http.httpErrorCode, userInfo: [NSLocalizedDescriptionKey: "Decoding error"])
                    success(ex, Optional.none)
                    return
                }
                success(Optional.none, res as? NSDictionary)
            }
        }
        task.resume()
    }
    
    /// graphql
    ///
    /// - Parameters:
    ///   - urlStr: url
    ///   - params: 参数
    ///   - success: block
    open func graphql(urlStr:String, params:String, success:@escaping (Error?, NSDictionary?) -> Void) {
        let url = URL(string: urlStr)
        let body = params.data(using: .utf8)
        var request = URLRequest(url: url!)
        request.timeoutInterval = Http.kTimeoutInterval
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/graphql", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared //单例
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil { //出错
                success(error, Optional.none)
            }else {
                guard let res = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else {
                    let ex = NSError(domain: Http.httpErrorDomain, code: Http.httpErrorCode, userInfo: [NSLocalizedDescriptionKey: "Decoding error"])
                    success(ex, Optional.none)
                    return
                }
                success(Optional.none, res as? NSDictionary)
            }
        }
        task.resume()
    }
    
    //MARK: ==== 上传带进度
    open func putWithProgress(urlStr:String, contentType:String, sufix:String, fileUrl: String, success:successBlock?,fail:failBlock?, progress: progressBlock?) {
        self.success = success
        self.fail = fail
        self.progress = progress
        let url = URL(string: urlStr)
        var request = URLRequest(url: url!)
        request.timeoutInterval = 10000
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(sufix, forHTTPHeaderField: "sufix")
        let config = URLSessionConfiguration.background(withIdentifier: fileUrl)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.uploadTask(with: request, fromFile: URL(fileURLWithPath: fileUrl))
        task.resume()
    }
    
    //MARK: =======  上传二进制 =======
    open func putDataWithProgress(urlStr:String, contentType:String, sufix:String, data: Data, success:successBlock?, fail:failBlock?, progress: progressBlock?) {
        self.success = success
        self.fail = fail
        self.progress = progress
        let url = URL(string: urlStr)
        var request = URLRequest(url: url!)
        request.timeoutInterval = 10000
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(sufix, forHTTPHeaderField: "sufix")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.uploadTask(with: request, from: data)
        task.resume()
    }

    //MARK: ===== URLSession Delegate ======
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let percent = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
        if progress != nil {
            DispatchQueue.main.async(execute: {
                [weak self] in
                self?.progress!(percent)
            })
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            if fail != nil {
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    self?.fail!((error?.localizedDescription)!)
                })
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if success != nil {
            let response = String(data: data, encoding: .utf8)
            if response != nil {
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    self?.success!(response!)
                })
            }
        }
    }
    
}
