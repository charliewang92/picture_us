//
//  ViewController.swift
//  Swiper
//
//  Created by 李秦琦 on 11/13/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit
import Social
import MessageUI
import AVFoundation
import AWSMobileHubHelper


class MasterController: UIViewController {
    static var mainViewcontroller: UIViewController?

    @IBOutlet var navigationBar: UINavigationItem!
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set title image
        presentSignInViewController()
        self.navigationItem.titleView = UIImageView(image:#imageLiteral(resourceName: "BarTitle"))
        signInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.defaultIdentityManager(), queue: OperationQueue.main, using: {[weak self] (note: Notification) -> Void in
            guard self != nil else { return }
            print("Sign In Observer observed sign in.")
            })
        
        signOutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignOut, object: AWSIdentityManager.defaultIdentityManager(), queue: OperationQueue.main, using: {[weak self](note: Notification) -> Void in
            guard self != nil else { return }
            print("Sign Out Observer observed sign out.")
            })

    }
    deinit {
        NotificationCenter.default.removeObserver(signInObserver)
        NotificationCenter.default.removeObserver(signOutObserver)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentSignInViewController() {
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignIn") as! SignInController
            present(signInViewController, animated: true, completion: nil)
        }

    }
}

