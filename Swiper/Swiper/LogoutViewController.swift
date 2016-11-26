//
//  LogoutViewController.swift
//  Swiper
//
//  Created by 李秦琦 and Charlie Wang  on 11/24/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit
import AWSMobileHubHelper


class LogoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        handleLogout()
    }

    func handleLogout() {
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {(result: Any?, error: Error?) -> Void in
                self.navigationController!.popToRootViewController(animated: false)
                MasterController.mainViewcontroller?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
                self.presentSignInViewController()
            })
        } else {
            assert(false)
        }
    }
    
    
    func presentSignInViewController() {
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignIn") as! SignInController
            present(signInViewController, animated: true, completion: nil)
        }
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
