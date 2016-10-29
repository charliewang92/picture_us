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
        print("in signin controller")
        
        
        
        
        // Google login scopes can be optionally set, but must be set
        // before user authenticates.
//        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
//        // Sets up the view controller that the Google signin will be launched from.
//        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
    
    }
    
    
    @IBAction func googleButton(_ sender: AnyObject) {
        handleGoogleLogin()
    }
    
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler:
            {(result: AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    /* Handle successful login. */
                }
                print("Login with signin provider result = \(result), error = \(error)")
        } as! (Any?, Error?) -> Void)
    }
    
    func handleGoogleLogin() {
        handleLoginWithSignInProvider(signInProvider: AWSGoogleSignInProvider.sharedInstance())
    }
    
    
    
}
