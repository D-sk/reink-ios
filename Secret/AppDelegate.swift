//
//  AppDelegate.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import AlamofireImage
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        SKPaymentQueue.default().add(StoreManager.shared)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        StoreManager.shared.fetchProducts()
        APIManager.shared.updateReceipt(onSuccess: {}, onFailure: { err in
            if let vc = application.keyWindow?.rootViewController {
                vc.present(AlertManager.shared.alertController(err), animated: true, completion: nil)
            }
        })
        
        if KeychainManager.shared.authToken.isEmpty == false {
            APIManager.shared.refreshToken(onSuccess:{ token in
                KeychainManager.shared.authToken = token
            }, onFailure: { err in
                let ac = AlertManager.shared.alertController(err)
                application.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
            })
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SKPaymentQueue.default().remove(StoreManager.shared)
    }

}

// Device Token
extension AppDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        APIManager.shared.updateDeviceToken(token, onSuccess: {
        }, onFailure: { err in
            debugPrint("Failed to enable notification, error: \(err)")
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to get token, error: \(error)")
    }
}

