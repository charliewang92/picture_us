//
//  ChangeSwipeDirectionViewController.swift
//  Swiper
//
//  Created by 李秦琦 and Charlie Wang  on 11/25/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ChangeSwipeDirectionViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var socialMediaScrollView: UIScrollView!
    
    var thumbButt: UIButton?
    var passedDirection: String! = ""
    let socialMediaTypes = [
        "facebook": #imageLiteral(resourceName: "FBIcon"), "twitter":#imageLiteral(resourceName: "TwitterIcon"), "imessage":#imageLiteral(resourceName: "iMessageIcon"), "weibo": #imageLiteral(resourceName: "WeiboIcon"), "google+":#imageLiteral(resourceName: "GIcon"), "deviantart": #imageLiteral(resourceName: "deviantart"), "flickr":#imageLiteral(resourceName: "FlickrIcon"), "tumblr":#imageLiteral(resourceName: "TumblrIcon"), "linkedin":#imageLiteral(resourceName: "LinkedInIcon")
    ]
     var socialMedia = [#imageLiteral(resourceName: "FBIcon"), #imageLiteral(resourceName: "TwitterIcon"), #imageLiteral(resourceName: "iMessageIcon"), #imageLiteral(resourceName: "GIcon"), #imageLiteral(resourceName: "FlickrIcon"), #imageLiteral(resourceName: "LinkedInIcon"), #imageLiteral(resourceName: "TumblrIcon"), #imageLiteral(resourceName: "WeiboIcon"),#imageLiteral(resourceName: "deviantart")]
    
     let buttonToSocialMedia = [
        0:"facebook", 1:"twitter", 2:"imessage", 3:"google+", 4:"flickr", 5:"linkedin", 6:"tumblr", 7:"weibo", 8:"deviantart"]
    
    @IBOutlet var currentMedia: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentMedia(socialMedia: passedDirection)
        self.initScrollView()
        socialMediaScrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonAction(_ sender: UIButton!) {
        let socialMedia = buttonToSocialMedia[sender.tag]
        currentMedia.image = socialMediaTypes[socialMedia!]
        updateNewSetting(newDirection: passedDirection, newMedia: socialMedia!)
        let alert = UIAlertController(title: "Swiper", message: "Updated social media " + socialMedia! + " for direction " + passedDirection, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateNewSetting(newDirection: String, newMedia: String) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        var uset = PictureUsUserSetting1()
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                    uset = tableRow
                    if newDirection == "up" {
                        uset?._up = newMedia
                    } else if newDirection == "down" {
                        uset?._down = newMedia
                    } else if newDirection == "left" {
                        uset?._left = newMedia
                    } else {
                        uset?._right = newMedia
                    }
                    dynamoDBObjectMapper.save(uset!, completionHandler: {(error: Error?) -> Void in
                        if let error = error {
                            print("Amazon DynamoDB Save Error: \(error)")
                            return
                        }
                        
                    })
                }
            } else {
                let alert = UIAlertController(title: "Swiper", message: "Unable to update settings, please restart app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return nil
        })
    }

    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews();
    }
    
    func initScrollView(){
        var x: CGFloat = 0
        let y: CGFloat = 10
        let buttonWidth:CGFloat = 100
        let buttonHeight: CGFloat = 100
        let buttonGap: CGFloat = 10
        let numberOfButtons = socialMedia.count
        
        for index in 0...numberOfButtons - 1 {
            let buttonTag = index
            let buttonImage:UIImage = socialMedia[index]
            let button = UIButton(type: UIButtonType.custom) as UIButton
            button.tag = buttonTag
            button.frame = CGRect(origin: CGPoint(x: x,y :y), size: CGSize(width: buttonWidth, height: buttonHeight))
            button.setImage(buttonImage, for: .normal)
            button.showsTouchWhenHighlighted = true

            button.addTarget(self, action: Selector("buttonAction:"), for: UIControlEvents.touchUpInside)
            x +=  buttonWidth + buttonGap
            socialMediaScrollView.addSubview(button)
        }
        
        
        let buttonsCountFloat = CGFloat(Int(numberOfButtons))
        let x_val = buttonWidth * CGFloat(buttonsCountFloat+4)
        socialMediaScrollView.contentSize = CGSize(width: x_val, height: y)
    }
    
    func setCurrentMedia(socialMedia:String) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                    if (socialMedia == "up") {
                        self.currentMedia.image = self.socialMediaTypes[tableRow._up!]
                    } else if (socialMedia == "down") {
                        self.currentMedia.image = self.socialMediaTypes[tableRow._down!]
                    } else if (socialMedia == "left") {
                        self.currentMedia.image = self.socialMediaTypes[tableRow._left!]
                    } else {
                        self.currentMedia.image = self.socialMediaTypes[tableRow._right!]
                    }
                }
            }
                return nil
        })
    }

}
