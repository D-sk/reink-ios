//
//  QRScannerViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/01.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: AbstractViewController {

    @IBOutlet weak var qrScannerView: QRScannerView!
    var session: AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView = UIView(frame: CGRect.zero)
    var _isCaptured:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.qrScannerView.delegate = self
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session = AVCaptureSession()
            session?.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            session?.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            qrScannerView.addVideoPreviewLayer(layer: videoPreviewLayer!)
            
            session?.startRunning()
            
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            
        } catch {
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QRScannerViewController: QRScannerViewDelegate{
    func closeButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        if _isCaptured {
            return
        }
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView.frame = barCodeObject!.bounds
                if _isCaptured == false {
                    _isCaptured = true
                    Friend.create(with: metadataObj, onSuccess: { [weak self] in

                        self?.dismiss(animated: true, completion: nil)
                        
                        }, onFailure: { [weak self] err in
                            
                            self?.dismiss(animated: true, completion: {
                                self?.presentAlertController(with: err)
                            })
                            
                    })
                }
            }
            
        }
        
    }
}
