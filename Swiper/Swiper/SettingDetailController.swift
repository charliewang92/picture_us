//
//  SettingDetailController.swift
//  Swiper
//
//  Created by 李秦琦 on 12/3/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit

class SettingDetailController: UITableViewController {
    @IBOutlet var saveToGallery: UISwitch!
    var cameraController: CameraController = CameraController(nibName: nil, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func stateChanged() {
        if self.saveToGallery.isOn {
            self.cameraController.saveToGallery = true
        } else {
            self.cameraController.saveToGallery = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

