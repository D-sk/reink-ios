//
//  UserNotificationManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/07/29.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import UserNotifications

class UserNotificationManager: NSObject {
    static let shared = UserNotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func registerNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            guard error == nil else {
                return
            }
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }
    
    fileprivate func updateIfNeeded() {
        guard let tvc = UIApplication.topViewController() else {
            return
        }
        if let vc = tvc as? FriendViewController {
            vc.messages()
        } else if tvc is MessageViewController {
            (tvc.presentingViewController as! FriendViewController).messages()
        }
    }
}

extension UserNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.updateIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Friend.list(onSuccess: nil, onFailure: nil)
        self.updateIfNeeded()
    }
}

