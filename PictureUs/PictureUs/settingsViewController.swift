//
//  settingsViewController.swift
//  Swiper
//
//  Created by Charlie Wang on 10/25/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import UIKit
import AWSMobileHubHelper


/**
 CG point issues
 
 http://stackoverflow.com/questions/37946990/cgrectmake-cgpointmake-cgsizemake-cgrectzero-cgpointzero-is-unavailable-in
 **/

class settingsViewController: UIViewController {
    
    /**
        These pan views allow us to move UIViews around with the image overlay. This may not be the best approach and we might
        need to consider using other snap or drop and drop methods
    **/
    @IBAction func PanFlickerImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func PanFacebookImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        }
    
    @IBAction func PanTumblrImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func PanGoogleImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        handleLogout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLogout() {
        if (AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            AWSIdentityManager.defaultIdentityManager().logout(completionHandler: {(result: Any?, error: Error?) -> Void in
                self.navigationController!.popToRootViewController(animated: false)
                ViewController.mainViewcontroller?.dismiss(animated: true, completion: nil)
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
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            present(signInViewController, animated: true, completion: nil)
        }
    }

    
    /**
     Inserting user settings, but currently not active until we integrate with dynamo.
    **/
//    func insertSettings() {
//        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        
//        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            if (task.error == nil) {
//                if (task.result != nil) {
//                    let tableRow = task.result as! PictureUsUserSetting1
//                    print(tableRow._iMessageText!)
//                }
//            } else {
//                print("Error: \(task.error)")
//                let alertController = UIAlertController(title: "Failed to get item from table.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
//                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
//                })
//                alertController.addAction(okAction)
//                self.presentViewController(alertController, animated: true, completion: nil)
//                
//            }
//            return nil
//        })
//    }
    
    /**
        Get user table row to populate data for the settings table. 
     Not yet integrated with Dynamo so commenting out for now.
     **/
//    func getTableRow() {
//        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        
//        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            if (task.error == nil) {
//                if (task.result != nil) {
//                    let tableRow = task.result as! PictureUsUserSetting1
//                    print(tableRow._iMessageText!)
//                }
//            } else {
//                print("Error: \(task.error)")
//                let alertController = UIAlertController(title: "Failed to get item from table.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
//                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
//                })
//                alertController.addAction(okAction)
//                self.presentViewController(alertController, animated: true, completion: nil)
//                
//            }
//            return nil
//        })
//    }


    
}
