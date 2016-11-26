//
//  SignInController.swift
//  Swiper
//
//  Created by Charlie Wang on 11/22/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import GoogleSignIn


class SignInController: UIViewController {
    var didSignInObserver: AnyObject!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        didSignInObserver =  NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.defaultIdentityManager(),queue: OperationQueue.main, using: {(note: Notification) -> Void in
            // perform successful login actions here
        })
        
        // Google login scopes can be optionally set, but must be set
        // before user authenticates.
        // Sets up the view controller that the Google signin will be launched from.
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"]);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler: {(result: Any?, error: Error?) -> Void in
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                print ("got in here after facebook?")
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            print("result = \(result), error = \(error)")
        })
    }
    
    @IBAction func googleLogin(_ sender: AnyObject) {
        handleGoogleLogin()
    }
    
    @IBAction func facebookLogin(_ sender: AnyObject) {
        handleFacebookLogin()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(didSignInObserver)
    }
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleGoogleLogin() {
        handleLoginWithSignInProvider(signInProvider: AWSGoogleSignInProvider.sharedInstance())
    }
    
    func handleFacebookLogin() {
        // Facebook login permissions can be optionally set, but must be set
        // before user authenticates.
        handleLoginWithSignInProvider(signInProvider: AWSFacebookSignInProvider.sharedInstance())
    }
    

}
