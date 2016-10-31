//
//  SignInViewController.swift
//  Swiper
//
//  Created by Charlie Wang on 10/28/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileHubHelper
import GoogleSignIn


class SignInViewController: UIViewController {
    
    var didSignInObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didSignInObserver =  NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.defaultIdentityManager(),queue: OperationQueue.main, using: {(note: Notification) -> Void in
            // perform successful login actions here
        })
        
        // Google login scopes can be optionally set, but must be set
        // before user authenticates.
        // Sets up the view controller that the Google signin will be launched from.
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
    
    }
    
    @IBAction func facebookButton(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Sign In", message: "Facebook Sign In Not Yet Supported!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func googleButton(_ sender: AnyObject) {
        handleGoogleLogin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(didSignInObserver)
    }
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {(result: Any?, error: Error?) -> Void in
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            print("result = \(result), error = \(error)")
        })
    }
    func handleGoogleLogin() {
        handleLoginWithSignInProvider(signInProvider: AWSGoogleSignInProvider.sharedInstance())
    }
}
