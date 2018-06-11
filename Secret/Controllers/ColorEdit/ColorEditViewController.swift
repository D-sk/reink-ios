//
//  ColorEditViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class ColorEditViewController: AbstractViewController {

    @IBOutlet fileprivate weak var _colorEditView: ColorEditView!
    var palette:UIColor.Palette = UIColor.Palette.green
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _colorEditView.delegate = self
        _colorEditView.setColorPalette(with: self.palette)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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

extension ColorEditViewController: ColorEditViewDelegate{
    func colorChanged(colorKey:Int) {
        let nvc = self.presentingViewController as? UINavigationController
        if let vc = nvc?.topViewController as? GroupEditViewController {
            vc.setColorKey(with: colorKey)
        }
    }
    
    func closeButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
