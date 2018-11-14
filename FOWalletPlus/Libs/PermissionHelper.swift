//
//  PermissionHelper.swift
//  Vernier
//
//  Created by Sleep on 31/03/2018.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Contacts
import UserNotifications

class PermissionHelper: NSObject {
    
    //MARK: === 检测相机是否有权限 ======
    open func checkCameraIsAllow(results: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (grant) in
                DispatchQueue.main.async(execute: {
                    results(grant)
                })
            })
        } else if status == .denied || status == .restricted {
            return results(false)
        } else {
            return results(true)
        }
    }
    
    //MARK: === 检测相册是否有权限 ======
    open func checkLibraryIsAllow(results: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (requestStatus) in
                DispatchQueue.main.async(execute: {
                    if status == .denied || status == .restricted {
                        results(false)
                    } else {
                        results(true)
                    }
                })
            })
        } else if status == .denied || status == .restricted {
            results(false)
        } else if status == .authorized {
            results(true)
        } else {
            results(false)
        }
    }
    
    //MARK: === 检测通讯录是否有权限 =====
    open func checkContactsIsAllow(results: @escaping (Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized {
            results(true)
        } else if status == .notDetermined {
            let contact = CNContactStore()
            contact.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                results(granted)
            })
        } else {
            results(false)
        }
    }
    
    //MARK: ==== 检测通知是否有权限 ======
    open func checkNotificationIsAllow(results: @escaping (Bool) -> Void) {
        if IOS(version: 10) {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings(completionHandler: { (settings) in
                DispatchQueue.main.async(execute: {
                    results(settings.authorizationStatus == .authorized)
                })
            })
        } else if IOS(version: 8) {
            let settings = UIApplication.shared.currentUserNotificationSettings
            results(settings?.types.rawValue != 0)
        } else {
            let type = UIApplication.shared.enabledRemoteNotificationTypes()
            results(type.rawValue != 0)
        }
    }
    
    open func toAppSetting() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        let application = UIApplication.shared
        if application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }
    }
    
}
