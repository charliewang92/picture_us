//
//  ViewController.swift
//  Swiper
//
//  Created by 李秦琦 and Charlie Wang on 11/13/16.
//  Copyright © 2016 BookishParakeet. All rights reserved.
//

import UIKit
import Social
import MessageUI
import AVFoundation
import AWSDynamoDB
import AWSMobileHubHelper

//Need to change where the default keeps getting set...
class CameraController:UIViewController, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var stillImageOutput : AVCaptureStillImageOutput?
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var firstTime: Bool = true
    var saveToGallery: Bool = true
    var appliedFilter: Bool = false
    var setSepia: Bool = false
    var setTempImage: Bool = false
    var tmpUIImage: UIImage!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var pictureImage: UIImageView!
    var phoneNumber: String!
    @IBOutlet var swipeLeftImg: UIImageView!
    @IBOutlet var swipeRightImg: UIImageView!
    @IBOutlet var swipeUpImg: UIImageView!
    @IBOutlet var swipeDownImg: UIImageView!
    
    @IBOutlet var applyFilterButton: UIButton!
    @IBOutlet var takeAnotherPhotoButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var imagePickerButton: UIButton!
    let imagePicker = UIImagePickerController()
    var didTakePhoto = Bool()
    
    @IBOutlet var leftImage: UIImageView!
    @IBOutlet var rightImage: UIImageView!
    @IBOutlet var upImage: UIImageView!
    @IBOutlet var downImage: UIImageView!
    
    let socialMediaTypes = [
        "facebook": #imageLiteral(resourceName: "FBIcon"), "twitter":#imageLiteral(resourceName: "TwitterIcon"), "imessage":#imageLiteral(resourceName: "iMessageIcon"), "weibo": #imageLiteral(resourceName: "WeiboIcon"), "google+":#imageLiteral(resourceName: "GIcon"), "flickr":#imageLiteral(resourceName: "FlickrIcon"), "tumblr":#imageLiteral(resourceName: "TumblrIcon"), "linkedin":#imageLiteral(resourceName: "LinkedInIcon"), "deviantart":#imageLiteral(resourceName: "deviantart")
    ]
    var socialMedia = [#imageLiteral(resourceName: "FBIcon"), #imageLiteral(resourceName: "TwitterIcon"), #imageLiteral(resourceName: "iMessageIcon"), #imageLiteral(resourceName: "GIcon"), #imageLiteral(resourceName: "FlickrIcon"), #imageLiteral(resourceName: "LinkedInIcon"), #imageLiteral(resourceName: "TumblrIcon"), #imageLiteral(resourceName: "WeiboIcon"), #imageLiteral(resourceName: "deviantart")]
    
    let buttonToSocialMedia = [
        0:"facebook", 1:"twitter", 2:"imessage", 3:"google+", 4:"flickr", 5:"linkedin", 6:"tumblr", 7:"weibo", 8:"deviantart"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignSwipeAction()
        imagePicker.delegate = self
        phoneNumber = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
        previewLayer?.frame = cameraView.bounds
    }

    func setup() {
        if(AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            setMediaIcons()
        }
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
        handleShareMedia(direction:"right")
    }
    
    func handleLeft() {
        handleShareMedia(direction:"left")
    }
    
    func handleDown() {
        handleShareMedia(direction:"down")
    }
    
    func handleUp() {
        handleShareMedia(direction:"up")
    }
    
    func handleShareMedia(direction:String!) {
        if(AWSIdentityManager.defaultIdentityManager().isLoggedIn) {
            shareWithuser(direction: direction)
        } else {
            shareDefault(direction: direction)
        }
    }
    
    //This is to make sure the user signs in INTO THE APP first before they try to share anything 
    //Otherwise app crashes because it tries to make AWS calls without the user signing in with facebook or google
    func shareDefault(direction: String!) {
        if direction == "up" {
            shareImageWithWeibo()
        } else if direction == "down" {
            sendImageMessage()
        } else if direction == "left" {
            shareImageWithFacebook()
        } else {
            shareImageWithTwitter()
        }
    }
    
    func shareWithuser(direction: String!) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                    if direction == "up" {
                        self.shareWithSocialMedia(socialMedia: tableRow._up)
                    } else if direction == "down" {
                        self.shareWithSocialMedia(socialMedia: tableRow._down)
                    } else if direction == "left" {
                        self.shareWithSocialMedia(socialMedia: tableRow._left)
                    } else {
                        self.shareWithSocialMedia(socialMedia: tableRow._right)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Swiper", message: "We did not get the direction you swiped!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)            }
            return nil
        })
    }
    
    func shareWithSocialMedia(socialMedia:String!) {
        if socialMedia == "imessage" {
            sendImageMessage()
        } else if socialMedia == "facebook" {
            shareImageWithFacebook()
        } else if socialMedia == "twitter" {
            shareImageWithTwitter()
        }else if socialMedia == "weibo" {
            shareImageWithWeibo()
        }else if socialMedia == "google+" {
            shareImageWithGoogle()
        }else if socialMedia == "flickr" {
            shareImageWithFlickr()
        }else if socialMedia == "tumblr" {
            shareImageWithTumblr()
        }else if socialMedia == "linkedin" {
            shareImageWithLinkedIn()
        }else if socialMedia == "deviantart" {
            shareImageWithDeviantart()
        }else {
            let alert = UIAlertController(title: "Swiper", message: "We do not have that social media yet", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
    
    func shareImageWithGoogle() {
        let alert = UIAlertController(title: "Google+", message: "Google+ integration soon to come!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareImageWithFlickr() {
        let alert = UIAlertController(title: "Flickr", message: "Flickr integration soon to come!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareImageWithTumblr() {
        let alert = UIAlertController(title: "Tumblr", message: "Tumblr integration soon to come!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareImageWithLinkedIn() {
            let alert = UIAlertController(title: "LinkedIn", message: "LinkedIn integration soon to come!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    func shareImageWithDeviantart() {
        let alert = UIAlertController(title: "Devianart", message: "Devianart integration soon to come!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
                    if (self.saveToGallery == true) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                    }
                    self.pictureImage.image = image
                    self.appliedFilter = false
                    self.setSepia = false;
                    self.setTempImage = false
                    self.imagePickerButton.setImage(image, for: UIControlState.normal)
                    self.view.bringSubview(toFront: self.takeAnotherPhotoButton)
                    self.view.bringSubview(toFront: self.applyFilterButton)
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
    
    func didPressTakeAnother(){
        if didTakePhoto == true{
            didTakePhoto = false
            self.view.sendSubview(toBack: pictureImage)
            self.view.sendSubview(toBack: swipeLeftImg)
            self.view.sendSubview(toBack: swipeRightImg)
            self.view.sendSubview(toBack: swipeUpImg)
            self.view.sendSubview(toBack: swipeDownImg)
            self.view.sendSubview(toBack: takeAnotherPhotoButton)
            self.view.sendSubview(toBack: applyFilterButton)
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
        if self.firstTime {
            self.didPressTakeAnother()
            self.firstTime = false
        }
    }
   
    @IBAction func takeAnotherPhoto(_ sender: AnyObject) {
        self.pictureImage.image = nil
        didPressTakeAnother()
        firstTime = true
    }
    
    
    @IBAction func pickImageFromLibrary(_ sender: AnyObject) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func setMediaIcons() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper .load(PictureUsUserSetting1.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: nil) .continue(with: AWSExecutor.mainThread(), with: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! PictureUsUserSetting1
                        self.setImages(leftSetting: tableRow._left!, rightSetting: tableRow._right!, upSetting: tableRow._up!, downSetting: tableRow._down!)
                } else {
                    //If no users yet, this will return null and we will insert a new user
                    self.insertSettings(leftSetting: "facebook", rightSetting: "twitter", upSetting: "weibo", downSetting: "imessage")
                    self.setDefaultImages()
                }
            } else {
                let alert = UIAlertController(title: "Swiper", message: "Login encountered an error!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return nil
        })
    }
    
    func setDefaultImages() {
        upImage.image = socialMediaTypes["weibo"]
        downImage.image = socialMediaTypes["imessage"]
        leftImage.image = socialMediaTypes["facebook"]
        rightImage.image = socialMediaTypes["twitter"]
    }
    
    func setImages (leftSetting: String, rightSetting: String, upSetting: String, downSetting: String) {
        upImage.image = socialMediaTypes[upSetting]
        downImage.image = socialMediaTypes[downSetting]
        leftImage.image = socialMediaTypes[leftSetting]
        rightImage.image = socialMediaTypes[rightSetting]
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

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        captureSession?.stopRunning()
        pictureImage.contentMode = .scaleAspectFill
        pictureImage.image = chosenImage
        appliedFilter = false
        setSepia = false
        setTempImage = false
        self.view.bringSubview(toFront: self.pictureImage)
        self.view.bringSubview(toFront: self.takeAnotherPhotoButton)
        self.view.bringSubview(toFront: self.applyFilterButton)
        self.view.bringSubview(toFront: self.swipeLeftImg)
        self.view.bringSubview(toFront: self.swipeRightImg)
        self.view.bringSubview(toFront: self.swipeUpImg)
        self.view.bringSubview(toFront: self.swipeDownImg)
        self.view.bringSubview(toFront: self.rightImage)
        self.view.bringSubview(toFront: self.leftImage)
        self.view.bringSubview(toFront: self.upImage)
        self.view.bringSubview(toFront: self.downImage)
        self.view.sendSubview(toBack: self.imagePickerButton)
        didTakePhoto = true
        dismiss(animated:true, completion: nil)
    }
    
    @IBAction func applyFilterToImage(_ sender: Any) {
        if setTempImage == false {
            tmpUIImage = self.pictureImage.image
            setTempImage = true
        }
        if appliedFilter == false {
            var filterName = "CIFalseColor"
            guard let image = self.tmpUIImage.cgImage else {
                let alert = UIAlertController(title: "Swiper", message: "Could not apply filter.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let openGLContext = EAGLContext(api: .openGLES3)
            let context = CIContext(eaglContext: openGLContext!)
            let ciImage = CIImage(cgImage: image)
            if setSepia == true {
                filterName = "CIPhotoEffectNoir"
                appliedFilter = true
            } else {
                setSepia = true
                filterName = "CIFalseColor"
            }
            let filter = CIFilter(name: filterName) // CISepiaTone
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                self.pictureImage?.image = UIImage(cgImage: context.createCGImage(output, from: output.extent)!, scale: 1.0, orientation: UIImageOrientation.right)
                
            }
        } else {
            self.pictureImage?.image = tmpUIImage
            appliedFilter = false
            setTempImage = false
            setSepia = false
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

