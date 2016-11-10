//
//  UserSettingsViewController.swift
//  Swiper
//
//  Created by Charlie Wang on 11/9/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class UserSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded in user settings")
        // Do any additional setup after loading the view.
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
    @IBAction func insertSetting(_ sender: AnyObject) {
        insertSettings()
    }
    @IBAction func getSettings(_ sender: AnyObject) {
        getTableRow()
    }
    
    func insertSettings() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let uset = PictureUsUserSetting1()
        
        uset?._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        uset?._circle = "V2.0"
        uset?._down = "Facebook"
        uset?._left = "TWITTERSaUCE"
        uset?._right = "iMessage"
        uset?._up = "none"
        uset?._iMessageText = "HELLO HELLO!"
        uset?._iMessageContacts = "6507778889,6509473423,41590909090"
        
        dynamoDBObjectMapper.save(uset!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            
            let alertController = UIAlertController(title: "Item saved!", message: uset?._userId, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            print("Item saved.")
        })
        
        //getTableRow()   //test get

    }
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                    print(tableRow._iMessageText!)
                    let alertController = UIAlertController(title: "Success! to get item from table.", message: "Your last text was: " + tableRow._iMessageText!, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            } else {
                print("Error: \(task.error)")
                let alertController = UIAlertController(title: "Failed to get item from table.", message: task.error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            return nil
        })
        
    

}

}
