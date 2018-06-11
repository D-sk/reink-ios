//
//  APIManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/12/17.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Alamofire

class APIManager: NSObject {
    public static let shared: APIManager = APIManager()

#if DEBUG
    static let endPoint = "http://localhost:8000"
#else
    static let endPoint = "https://n2p-api.fiole.co"
#endif
    
    enum AuthRequest: String{
        case register = "register"
        case cdereq = "cdereq"
        case activate = "activate"
        case login = "login"
        case logout = "logout"
        case refresh = "refresh"
        
        case users = "users"
        
        func urlString() -> String {
            return endPoint + "/auth/v1/" + self.rawValue + "/"
        }
    }
    
    enum SecretRequest: String {
        case accounts = "accounts"
        case devices = "devices"
        case friends = "friends"
        case messages = "messages"
        case subscriptions = "subscriptions"
        
        func urlString() -> String {
            return endPoint + "/reink/v1/" + self.rawValue + "/"
        }
    }
        
    private func requestHeader() -> Dictionary<String, String> {
        var header:Dictionary<String, String> = [String:String]()
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            header["APP-VERSION"] = version
            header["APP-PLATFORM"] = "1"
        }
        
        if KeychainManager.shared.authToken.isEmpty == false {
            header["Authorization"] = "JWT " + KeychainManager.shared.authToken
        }
        return header
    }

    private func handleResponse(_ response: DataResponse<Any>,
                                onSuccess:@escaping (_ value:Dictionary<String,Any>)->Void,
                                onFailure:@escaping (_ error:NSError)->Void){
        switch response.result {
        case .success(let value):
            var content = [String:Any]()
            if let c = value as? Dictionary<String, Any> {
                content = c
            }
            if let statusCode = response.response?.statusCode{
                switch statusCode/100 {
                case 2:
                    onSuccess(content)
                default:
                    debugPrint(content)
                    let e = NSError(domain: Consts.appErrDomain, code:statusCode, userInfo: content)
                    onFailure(e)
                }
            }
            
        case .failure(let e):
            if let cde = response.response?.statusCode {
                let e = NSError(domain: Consts.appErrDomain, code:cde, userInfo: nil)
                onFailure(e)
            } else {
                onFailure(e as NSError)
            }
        }
    }
    
    fileprivate func apiRequest(_ method: Alamofire.HTTPMethod,
                    URLString:URLConvertible,
                    parameters: [String:Any]?,
                    encoding: ParameterEncoding,
                    onSuccess:@escaping (_ value:Dictionary<String,Any>)->Void,
                    onFailure:@escaping (_ error:NSError)->Void){
        
        let headers = self.requestHeader()
        var params:Dictionary<String,Any> = [String:Any]()
        if parameters != nil {
            params = parameters!
        }
        Alamofire.request(URLString, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON{ [weak self] response in
            self?.handleResponse(response, onSuccess: onSuccess, onFailure: onFailure)
        }
    }
    
    fileprivate func apiUpload(_ method:Alamofire.HTTPMethod,
                   data:Data,
                   URLString:URLConvertible,
                   parameters: [String:String],
                   onSuccess:@escaping (_ value:Dictionary<String,Any>)->Void,
                   onFailure:@escaping (_ error:NSError)->Void){
        
        Alamofire.upload(multipartFormData: { multiPartFormData in
            multiPartFormData.append(data, withName: "thumbnail", fileName: "test.jpeg", mimeType: "image/jpeg")
            for p in parameters {
                multiPartFormData.append(p.value.data(using: .utf8)!, withName: p.key)
            }
        }, usingThreshold: UInt64.init(), to: URLString, method: method, headers: self.requestHeader(), encodingCompletion: { result in

            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { [weak self] response in
                    self?.handleResponse(response, onSuccess: onSuccess, onFailure: onFailure)
                }
                
            case .failure(let err):
                onFailure(err as NSError)
            }
        })
    }

}

//// Authentication ////
// Users
extension APIManager {
    
    //POST
    func register(uname:String, pass:String, onSuccess:@escaping(String, String)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.register.urlString()
        let params = ["username":uname, "password":pass]
        
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            guard let uname = dict["username"] as? String, let uuid = dict["uuid"] as? String else {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                return
            }
            onSuccess(uname, uuid)
            
        },onFailure: {error in
            onFailure(error)
        })
    }

    func codeRequest(email:String, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.cdereq.urlString()
        let params = [
            "uuid":KeychainManager.shared.uuid,
            "email":email
        ]
        
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    func activate(code:String, onSuccess:@escaping(String)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.activate.urlString()
        let params = [
            "uuid":KeychainManager.shared.uuid,
            "username":KeychainManager.shared.uname,
            "code":code
        ]
        
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            
            guard let token = dict["token"] as? String else {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                return
            }
            onSuccess(token)
            
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    func login(uname:String, pass:String, onSuccess:@escaping(Dictionary<String,Any>, String)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.login.urlString()
        let params = ["username":uname, "password":pass]
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            
            guard let user = dict["user"] as? Dictionary<String,Any>, let token = dict["token"] as? String else {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                return
            }
            onSuccess(user, token)
            
            
        },onFailure: {error in
            onFailure(error)
        })
    }

    func logout(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.logout.urlString()
        self.apiRequest(.post, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: { dict in
            resetAll()
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    func refreshToken(onSuccess:@escaping(String)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.refresh.urlString()
        let params = ["token": KeychainManager.shared.authToken]
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: { dict in
            
            guard let token = dict["token"] as? String else {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                return
            }
            
            onSuccess(token)
            
        },onFailure: {error in
            
            onFailure(error)
        })
    }
    
    //GET
    func user(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.users.urlString()
        self.apiRequest(.get, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: { dict in
            resetAll()
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }

    //PATCH
    func updatePassword(password:String, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.users.urlString()
        let params = ["password":password]
        self.apiRequest(.patch, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    //DELETE
    func withdraw(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = AuthRequest.users.urlString()
        self.apiRequest(.delete, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }

}

///// Secret //////
// Accounts
extension APIManager {
    
    //POST
    func createAccount(_ account:Account, withThumbnail:UIImage?, onSuccess:@escaping(Dictionary<String, Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.accounts.urlString()
        let params = account.objToDict()
        //multipart
        if let data = withThumbnail?.data() {
            self.apiUpload(.post, data: data, URLString: urlString, parameters: params, onSuccess: { dict in
                onSuccess(dict)
            }, onFailure: { error in
                onFailure(error)
            })

        } else {
            self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
                onSuccess(dict)
            },onFailure: {error in
                onFailure(error)
            })
        }
    }
    
    //GET
    func account(with accountID:Int, onSuccess:@escaping(Dictionary<String, Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.accounts.urlString() + String(accountID) + "/"
        self.apiRequest(.get, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess(dict)
        },onFailure: {error in
            onFailure(error)
        })
    }

    //PATCH
    func updateAccount(account:Account, withThumbnail:UIImage?, onSuccess:@escaping(Dictionary<String, Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.accounts.urlString() + String(account.id) + "/"
        let params = account.objToDict()
        if let data = withThumbnail?.data() {
            self.apiUpload(.patch, data: data, URLString: urlString, parameters: params, onSuccess: { dict in
                onSuccess(dict)
            }, onFailure: { error in
                onFailure(error)
            })
            
        } else {
            self.apiRequest(.patch, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: { dict in
                onSuccess(dict)
            },onFailure: {error in
                onFailure(error)
            })
        }
    }
    
    
    //DELETE
    func deleteAccount(account:Account, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.accounts.urlString() + String(account.id) + "/"
        self.apiRequest(.delete, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }

}

// Devices
extension APIManager {
    
    //PUT
    func updateDeviceToken(_ token:String, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.devices.urlString()
        let params:[String : Any] = [
            "platform":1,
            "device_token":token
        ]
        
        self.apiRequest(.put, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: { _ in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
        
    }
}

// Recipt
extension APIManager {

    private func receiptParams() -> Dictionary<String,Any>? {
        guard let receipt = StoreManager.shared.receiptString else {
            return nil
        }
        return [ "receipt_data": receipt, "platform": 1]
    }
    
    func updateReceipt(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        
        let urlString = SecretRequest.subscriptions.urlString()
        guard let params = self.receiptParams() else {
            return
        }

        self.apiRequest(.put, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: { dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })

    }
    
}

// Friends
extension APIManager {
    
    //POST
    func createFriend(params:[String:Any], onSuccess:@escaping(Dictionary<String,Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.friends.urlString()
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess(dict)
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    //GET
    func friends(updatedAt:Date?=nil, onSuccess:@escaping([Dictionary<String,Any>])->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.friends.urlString()
        var params = [String:Any]()
        if updatedAt != nil {
            params = ["since": updatedAt!]
        }
        self.apiRequest(.get, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            guard let objects = dict["friends"] as? [Dictionary<String,Any>] else {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                return
            }
            onSuccess(objects)
        },onFailure: {error in
            onFailure(error)
        })
    }

    func retreiveFriend(_ friend:Friend, onSuccess:@escaping(Dictionary<String,Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.friends.urlString() + String(friend.id) + "/"
        self.apiRequest(.get, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess(dict)
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    // PATCH
    func muteFriend(_ friend:Friend, onSuccess:@escaping(Dictionary<String,Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.friends.urlString() + String(friend.id) + "/"
        let params = ["is_muted": !friend.isMuted]
        self.apiRequest(.patch, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess(dict)
        },onFailure: {error in
            onFailure(error)
        })
    }

    func unlinkFriend(_ friend:Friend, onSuccess:@escaping(Dictionary<String,Any>)->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.friends.urlString() + String(friend.id) + "/"
        let params = ["is_unlinked": !friend.isMuted]
        self.apiRequest(.patch, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess(dict)
        },onFailure: {error in
            onFailure(error)
        })
    }

    //DELETE
    func deleteFriend(_ friend:Friend, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.friends.urlString() + String(friend.id) + "/"
        self.apiRequest(.delete, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }
}

// Message
extension APIManager {
    //POST
    func sendMessage(to friend:Friend, body:String, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.messages.urlString()
        let params:Dictionary<String,Any> = ["receiver":friend.account!.id, "body":body]
        self.apiRequest(.post, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    //GET
    func messages(with:Friend, onSuccess:@escaping(_ messagse:[Dictionary<String,Any>])->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.messages.urlString()
        let params = ["sender":with.account!.id]
        self.apiRequest(.get, URLString: urlString, parameters: params, encoding: URLEncoding.default, onSuccess: {dict in
            guard let objects = dict["messages"] as? [Dictionary<String,Any>] else {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                return
            }
            onSuccess(objects)
            
        },onFailure: {error in
            onFailure(error)
        })
    }
    
    //DELETE
    func deleteMessage(message:Message, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        let urlString = SecretRequest.messages.urlString() + String(message.id) + "/"
        
        self.apiRequest(.delete, URLString: urlString, parameters: nil, encoding: URLEncoding.default, onSuccess: {dict in
            onSuccess()
        },onFailure: {error in
            onFailure(error)
        })
    }


}

