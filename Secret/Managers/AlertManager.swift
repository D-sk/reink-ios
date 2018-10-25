//
//  AlertManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/23.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

enum AlertType : Int{
    // Defaults
    case internalError = 500
    //API | Netowrk
    case badRequest = 400
    case authError = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case notAllowed = 405
    case networkError = 999
    //Information
    case contactConfirmation = 101
    case photoAccessGrant = 102
    case thumbnailChange = 103
    case friendDeleteConfirmation = 104
    case logoutConfrimation = 105
    case restoreConfirmation = 106
    case passwordChanged = 107
    case emailChanged = 108
    case withdrawConfirmation = 109
    

    func title() -> String{
        let comment = "AlertTitle"
        let key = comment + String(self.rawValue)
        return NSLocalizedString(key, comment: comment)
    }
    
    func message() -> String{
        let comment = "AlertMessage"
        let key = comment + String(self.rawValue)
        return NSLocalizedString(key, comment: comment)
    }
    
    func hasCancel() -> Bool{
        switch self{
        case .contactConfirmation,
             .friendDeleteConfirmation,
             .logoutConfrimation,
             .restoreConfirmation,
             .withdrawConfirmation:  
            return true
        default:
            return false
        }
    }
    
    func okButtonTitle() -> String{
        switch self{
        default:
            return "OK"
        }
    }
    
    func cancelButtonTitle() -> String{
        switch self{
        default:
            return "Cancel"
        }
    }
    
}

class AlertManager: NSObject {

    static let shared: AlertManager = AlertManager()

    func alertController(_ type:AlertType, handler: (()->Void)?, cancelHandler:(()->Void)?) -> UIAlertController{
        let alertController = UIAlertController(title: type.title(), message: type.message(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: type.okButtonTitle(), style: .default, handler: { action in handler?()})
        alertController.addAction(okAction)
        if type.hasCancel() || cancelHandler != nil{
            let cancelAction = UIAlertAction(title: type.cancelButtonTitle(), style: .cancel, handler:{ action in cancelHandler?()})
            alertController.addAction(cancelAction)
        }
        return alertController
    }
    
    func alertController(_ title:String?, message:String?, handler: (()->Void)?, cancelHandler:(()->Void)?) -> UIAlertController{
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in handler?()}))
        if cancelHandler != nil {
            ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in cancelHandler!()}))
        }
        return ac
    }
    
    func alertController(_ error:NSError) -> UIAlertController{
        guard let type = AlertType(rawValue: error.code) else {
            if error.localizedDescription.isEmpty {
                return alertController(.internalError, handler: nil, cancelHandler: nil)
            } else {
                return alertController(nil, message: error.localizedDescription, handler: nil, cancelHandler: nil)
            }
        }
        
        if type == .authError {
            return self.alertController(.authError, handler: {
                if !(UIApplication.topViewController() is RegistrationViewController) {
                    resetAll()
                    UIApplication.shared.keyWindow?.rootViewController = InitialViewController.instantiate()
                }
            }, cancelHandler: nil)
        
        }
        
        if type == .paymentRequired {
            return self.alertController(.authError, handler: {
                StoreManager.shared.openManagementSubscription()
            }, cancelHandler: nil)
        }
        
        return self.alertController(type, handler: nil, cancelHandler: nil)
    }
    
    func thumbnailChangeAlertController(photoAction:@escaping ()->Void, libraryAction:@escaping ()->Void)->UIAlertController{
        let alertType = AlertType.thumbnailChange
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let ct =  "カメラ"
        let camera = UIAlertAction(title:ct, style: .default, handler:{(action:UIAlertAction!) -> Void in
            photoAction()
        })
        let lt = "写真を選択"
        let library = UIAlertAction(title:lt, style: .default, handler:{(action:UIAlertAction!) -> Void in
            libraryAction()
        })
        let cancel =  UIAlertAction(title: alertType.cancelButtonTitle(), style: UIAlertActionStyle.cancel, handler:nil)
        alertController.addAction(camera)
        alertController.addAction(library)
        alertController.addAction(cancel)
        return alertController
    }
    
}
