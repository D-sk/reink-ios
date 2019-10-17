//
//  PLManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/08.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Photos

class PLManager: NSObject {
    
    static let shared: PLManager = PLManager()
    var completion:((_ completed:Bool, _ image:UIImage?, _ fileName:String?)->Void)!
    

    func cameraController(completion:@escaping (_ completed:Bool, _ image:UIImage?, _ fileName:String?)->Void) -> UIImagePickerController?{
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
        case .denied, .restricted:
            return nil
        default:
            break
        }
        
        self.completion = completion
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.camera
            return controller
        }
        return nil
    }
    
    func requestLibraryAccess(onGrant: (()->Void)?, onDeny:(()->Void)?) {
        PHPhotoLibrary.requestAuthorization({ (status) in
            switch status {
            case .restricted, .denied:
                onDeny?()
            default:
                onGrant?()
            }
        })
    }
    
    func libraryController(completion:@escaping (_ completed:Bool, _ image:UIImage?, _ fileName:String?)->Void) -> UIImagePickerController?{
        
        switch PHPhotoLibrary.authorizationStatus(){
        case .restricted, .denied:
            return nil
        default:
            break
        }
        
        self.completion = completion
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            return controller
        }
        return nil
    }

}

extension PLManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let url = info[UIImagePickerControllerReferenceURL] as? URL{
            
            var fileName:String?
            if let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject{
                fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename
            }
            picker.dismiss(animated: true, completion: {
                self.completion(true, image, fileName)
            })
        }else{
            picker.dismiss(animated: true, completion: {
                if image != nil{ UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.imageDidSave(_:didFinishSavingWithError:contextInfo:)), nil) }
            })
        }
    }
    
    @objc func imageDidSave(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        
        if error == nil {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let photos = PHAsset.fetchAssets(with: .image, options: options)
            if let asset = photos.firstObject{
                let imgReqOptions = PHImageRequestOptions()
                imgReqOptions.isSynchronous = true
                PHImageManager.default().requestImageData(for: asset, options: imgReqOptions,resultHandler: {imageData, dataUTI, orientation, info in
                    if info != nil {
                        var fileName = ""
                        if let path = info!["PHImageFileURLKey"] as? URL{
                            fileName = path.absoluteString.components(separatedBy: "/").last!
                        }
                        self.completion(true, image, fileName)
                    }
                })
            }
        }else{
            self.completion(false, nil, nil)
        }
    }
}
