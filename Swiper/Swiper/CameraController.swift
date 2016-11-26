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
import AWSDynamoDB
import AWSMobileHubHelper


class CameraController:UIViewController, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var stillImageOutput : AVCaptureStillImageOutput?
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var firstTime: Bool = true
    @IBOutlet var cameraView: UIView!
    @IBOutlet var pictureImage: UIImageView!
    var phoneNumber: String!
    @IBOutlet var swipeLeftImg: UIImageView!
    @IBOutlet var swipeRightImg: UIImageView!
    @IBOutlet var swipeUpImg: UIImageView!
    @IBOutlet var swipeDownImg: UIImageView!
    
    @IBOutlet var takeAnotherPhotoButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var imagePickerButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var leftImage: UIImageView!
    @IBOutlet var rightImage: UIImageView!
    @IBOutlet var upImage: UIImageView!
    @IBOutlet var downImage: UIImageView!
    var firstLogin = true

    let socialMediaTypes = [
        "facebook": #imageLiteral(resourceName: "FBIcon"), "twitter":#imageLiteral(resourceName: "TwitterIcon"), "imessage":#imageLiteral(resourceName: "iMessageIcon"), "weibo": #imageLiteral(resourceName: "WeiboIcon"), "google+":#imageLiteral(resourceName: "GIcon"), "flickr":#imageLiteral(resourceName: "FlickrIcon"), "tumblr":#imageLiteral(resourceName: "TumblrIcon"), "linkedin":#imageLiteral(resourceName: "LinkedInIcon")
    ]
    var socialMedia = [#imageLiteral(resourceName: "FBIcon"), #imageLiteral(resourceName: "TwitterIcon"), #imageLiteral(resourceName: "iMessageIcon"), #imageLiteral(resourceName: "GIcon"), #imageLiteral(resourceName: "FlickrIcon"), #imageLiteral(resourceName: "LinkedInIcon"), #imageLiteral(resourceName: "TumblrIcon"), #imageLiteral(resourceName: "WeiboIcon")]
    
    let buttonToSocialMedia = [
        0:"facebook", 1:"twitter", 2:"imessage", 3:"google+", 4:"flickr", 5:"linkedin", 6:"tumblr", 7:"weibo"]
    


    override func viewDidLoad() {
        super.viewDidLoad()
        assignSwipeAction()
        imagePicker.delegate = self
    }
    
    
    func assignSwipeAction() {
        let upRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CameraController.handleUp))
        upRecognizer.direction = UISwipeGestureRecognizerDirection.up
        self.view?.addGestureRecognizer(upRecognizer)
        
        let downRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CameraController.handleDown))
        downRecognizer.direction = UISwipeGestureRecognizerDirection.down
        self.view?.addGestureRecognizer(downRecognizer)
        
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CameraController.handleLeft))
        leftRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(leftRecognizer)
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CameraController.handleRight))
        rightRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(rightRecognizer)
    }
    
    func handleRight() {
        shareImageWithTwitter()
    }
    
    func handleLeft() {
        shareImageWithFacebook()
    }
    
    func handleDown() {
        sendImageMessage()
    }
    
    func handleUp() {
        shareImageWithWeibo()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLogin == true {
            self.setDefaults()
            firstLogin = false
        } else {
            setMediaIcons()
        }
        print ("viewdid appear")
        previewLayer?.frame = cameraView.bounds

    }
    
    func sendImageMessage() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.addAttachmentData(UIImageJPEGRepresentation(pictureImage.image!, 1)!, typeIdentifier: "image/jpg", filename: "images.jpg")
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func shareImageWithFacebook() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            facebookSheet.add(pictureImage.image)
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func shareImageWithTwitter() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            twitterSheet.add(pictureImage.image)
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     sharing image with weibo
     **/
    func shareImageWithWeibo() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTencentWeibo){
            let weiboSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTencentWeibo)
            weiboSheet.setInitialText("Share on Weibo")
            weiboSheet.add(pictureImage.image)
            self.present(weiboSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Weibo account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }

    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error : NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error == nil && captureSession?.canAddInput(input) != nil){
            
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput) != nil){
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
                
            }
        }
    }
    
    func didPressTakePhoto(){
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
                (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider  = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent )
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    
                    self.pictureImage.image = image
                    self.view.bringSubview(toFront: self.takeAnotherPhotoButton)
                    self.view.bringSubview(toFront: self.swipeLeftImg)
                    self.view.bringSubview(toFront: self.swipeRightImg)
                     self.view.bringSubview(toFront: self.swipeUpImg)
                     self.view.bringSubview(toFront: self.swipeDownImg)
                    self.view.bringSubview(toFront: self.rightImage)
                     self.view.bringSubview(toFront: self.leftImage)
                     self.view.bringSubview(toFront: self.upImage)
                     self.view.bringSubview(toFront: self.downImage)
                    self.view.sendSubview(toBack: self.imagePickerButton)
                    
                
                }
            })
        }
        self.view.bringSubview(toFront: pictureImage)
    }
    
    var didTakePhoto = Bool()
    func didPressTakeAnother(){
        if didTakePhoto == true{
            didTakePhoto = false
            self.view.sendSubview(toBack: pictureImage)
            self.view.sendSubview(toBack: swipeLeftImg)
            self.view.sendSubview(toBack: swipeRightImg)
            self.view.sendSubview(toBack: swipeUpImg)
            self.view.sendSubview(toBack: swipeDownImg)
            self.view.sendSubview(toBack: takeAnotherPhotoButton)
            self.view.bringSubview(toFront: imagePickerButton)
            self.view.sendSubview(toBack: leftImage)
            self.view.sendSubview(toBack: rightImage)
            self.view.sendSubview(toBack: upImage)
            self.view.sendSubview(toBack: downImage)
        }
        else{
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
    }

    @IBAction func takePhoto(_ sender: AnyObject) {
        if firstTime {
            didPressTakeAnother()
            firstTime = false
        }
    }
   
    @IBAction func takeAnotherPhoto(_ sender: AnyObject) {
        self.pictureImage.image = nil
        didPressTakeAnother()
        firstTime = true
    }
    
    
    @IBAction func pickImageFromLibrary(_ sender: AnyObject) {
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//        
//        present(imagePicker, animated: true, completion: nil)
        let alert = UIAlertController(title: "Image Picker", message: "Image Picker feature coming soon!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            pictureImage.contentMode = .scaleAspectFit
//            pictureImage.image = pickedImage
//            self.view.bringSubview(toFront: self.takeAnotherPhotoButton)
//            self.view.bringSubview(toFront: self.swipeLeftImg)
//            self.view.bringSubview(toFront: self.swipeRightImg)
//            self.view.bringSubview(toFront: self.swipeUpImg)
//            self.view.bringSubview(toFront: self.swipeDownImg)
//            self.view.sendSubview(toBack: self.imagePickerButton)
//            
//        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func setMediaIcons() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                    self.setImages(leftSetting: tableRow._left!, rightSetting: tableRow._right!, upSetting: tableRow._up!, downSetting: tableRow._down!)
                }
            } else {
                self.setDefaults()
            }
            return nil
        })
    }
    
    func setDefaults() {
        print ("setting defaults")
        upImage.image = socialMediaTypes["weibo"]
        downImage.image = socialMediaTypes["imessage"]
        leftImage.image = socialMediaTypes["facebook"]
        rightImage.image = socialMediaTypes["twitter"]
        phoneNumber = ""
    }
    
    func setImages (leftSetting: String, rightSetting: String, upSetting: String, downSetting: String) {
        print ("setting from db")
        upImage.image = socialMediaTypes[upSetting]
        downImage.image = socialMediaTypes[downSetting]
        leftImage.image = socialMediaTypes[leftSetting]
        rightImage.image = socialMediaTypes[rightSetting]
    }

}

