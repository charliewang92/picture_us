//
//  ViewController.swift
//  Swiper
//
//  Created by 李秦琦 and Charlie Wang  on 11/13/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB


class GestureDetailsController: UITableViewController {
    @IBOutlet var upImage: UIImageView!
    @IBOutlet var downImage: UIImageView!
    @IBOutlet var leftImage: UIImageView!
    @IBOutlet var rightImage: UIImageView!
    var results: PictureUsUserSetting1!
    
    let socialMediaTypes = [
        "facebook": #imageLiteral(resourceName: "FBIcon"), "twitter":#imageLiteral(resourceName: "TwitterIcon"), "imessage":#imageLiteral(resourceName: "iMessageIcon"), "weibo": #imageLiteral(resourceName: "WeiboIcon"), "google+":#imageLiteral(resourceName: "GIcon"), "flickr":#imageLiteral(resourceName: "FlickrIcon"), "tumblr":#imageLiteral(resourceName: "TumblrIcon"), "linkedin":#imageLiteral(resourceName: "LinkedInIcon"), "deviantart":#imageLiteral(resourceName: "deviantart")
    ]
    var socialMedia = [#imageLiteral(resourceName: "FBIcon"), #imageLiteral(resourceName: "TwitterIcon"), #imageLiteral(resourceName: "iMessageIcon"), #imageLiteral(resourceName: "GIcon"), #imageLiteral(resourceName: "FlickrIcon"), #imageLiteral(resourceName: "LinkedInIcon"), #imageLiteral(resourceName: "TumblrIcon"), #imageLiteral(resourceName: "WeiboIcon"),#imageLiteral(resourceName: "deviantart")]
    
    let buttonToSocialMedia = [
        0:"facebook", 1:"twitter", 2:"imessage", 3:"google+", 4:"flickr", 5:"linkedin", 6:"tumblr", 7:"weibo", 8:"devianart"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMediaIcons()
    }
    
    @IBOutlet var upTableCell: UITableViewCell!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setMediaIcons() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                    if (tableRow._downLeft == nil) {
                        self.setDefaults()
                    } else {
                         self.setImages(leftSetting: tableRow._left!, rightSetting: tableRow._right!, upSetting: tableRow._up!, downSetting: tableRow._down!)
                    }
                }
            } else {
                self.setDefaults()
            }
            return nil
        })
    }
    
    //Insert users
    func insertSettings(leftSetting: String, rightSetting: String, upSetting: String, downSetting: String) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let uset = PictureUsUserSetting1()
        
        uset?._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        uset?._circle = "V2.0"
        uset?._down = downSetting
        uset?._left = leftSetting
        uset?._right = rightSetting
        uset?._up = upSetting
        uset?._circle="unsetCircle"
        uset?._doubleTap="unsetDoubleTap"
        uset?._downLeft="unsetDownLeft"
        uset?._downRight="unsetDownRight"
        uset?._iMessageContacts="UnsetContacts"
        uset?._iMessageText="unsetMessageText"
        uset?._tap="unsetTap"
        uset?._upLeft="unsetLeft"
        uset?._upRight="unsetRight"
        
        dynamoDBObjectMapper.save(uset!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            
        })
    }
    
    func setDefaults() {
        upImage.image = socialMediaTypes["weibo"]
        downImage.image = socialMediaTypes["imessage"]
        leftImage.image = socialMediaTypes["facebook"]
        rightImage.image = socialMediaTypes["twitter"]
        insertSettings(leftSetting: "facebook", rightSetting: "twitter", upSetting: "weibo", downSetting: "imessage")
    }
    
    func setImages (leftSetting: String, rightSetting: String, upSetting: String, downSetting: String) {
        upImage.image = socialMediaTypes[upSetting]
        downImage.image = socialMediaTypes[downSetting]
        leftImage.image = socialMediaTypes[leftSetting]
        rightImage.image = socialMediaTypes[rightSetting]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC: ChangeSwipeDirectionViewController = segue.destination as! ChangeSwipeDirectionViewController
        if (segue.identifier == "swipeUpSegue") {
            nextVC.passedDirection = "up"
        } else if (segue.identifier == "swipeDownSegue") {
            nextVC.passedDirection = "down"
        } else if (segue.identifier == "swipeLeftSegue") {
            nextVC.passedDirection = "left"
        } else {
            nextVC.passedDirection = "right"
        }
    }
    
    
}

