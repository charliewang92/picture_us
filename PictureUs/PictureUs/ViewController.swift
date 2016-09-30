//
//  ViewController.swift
//  PictureUs
//
//  Created by Charlie Wang on 9/23/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController {
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let v2 : View2 = View2(nibName: "cameraView", bundle: nil)
//        
//        self.addChildViewController(v2)
//        self.scrollView.addSubview(v2.view)
//        v2.didMove(toParentViewController: self)
//        
//        var v2Frame : CGRect = v2.view.frame
//        v2Frame.origin.x = self.view.frame.width
//        v2.view.frame = v2Frame
//        
//        self.scrollView.contentSize = CGSize(width: self.view.frame.width * 3, height: self.view.frame.height)
    }
    @IBAction func twitterPush(_ sender: AnyObject) {
        print("twitter pushed, will try and share")
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func facebookPush(_ sender: AnyObject) {
        print("facebook pushed, will try and share")
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

