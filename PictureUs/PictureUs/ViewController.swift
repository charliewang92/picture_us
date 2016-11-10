//
//  ViewController.swift
//  PictureUs
//
//  Created by Charlie Wang on 9/23/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import UIKit
import Social
import MessageUI
import AVFoundation
import AWSMobileHubHelper


/**
 This class will handle most of the logic that coordinates camera usage and image sharing
**/
class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Maintain access to this view controller
    static var mainViewcontroller: UIViewController?

    @IBOutlet var leftArrow: UIImageView!
    @IBOutlet var rightArrow: UIImageView!
    @IBOutlet var downArrow: UIImageView!
    @IBOutlet var upArrow: UIImageView!
    
    @IBOutlet var settingPageButton: UIButton!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    let picker = UIImagePickerController()
    var phoneNumber: String!
    
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var takeAnotherButton: UIButton!
    
    @IBOutlet var userSettingsButton: UIButton!
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var firstTime: Bool = true
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!
    
    var demoFeature: DemoFeature!
    
    override func viewDidLoad() {
        presentSignInViewController()
        ViewController.mainViewcontroller = self
        super.viewDidLoad()
         picker.delegate = self
         phoneNumber = ""
        assignSwipeAction()
        imageView.addSubview(leftArrow)
        imageView.addSubview(rightArrow)
        imageView.addSubview(downArrow)
        imageView.addSubview(upArrow)
        
        
        
        signInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.defaultIdentityManager(), queue: OperationQueue.main, using: {[weak self] (note: Notification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign In Observer observed sign in.")
            })
        
        signOutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignOut, object: AWSIdentityManager.defaultIdentityManager(), queue: OperationQueue.main, using: {[weak self](note: Notification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign Out Observer observed sign out.")
            })
        
        
        
        
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("User Sign-in",
                                    comment: "Label for demo menu option."),
            detail: NSLocalizedString("Enable user login with popular 3rd party providers.",
                                      comment: "Description for demo menu option."),
            icon: "UserIdentityIcon", storyboard: "UserSettings")
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(signInObserver)
        NotificationCenter.default.removeObserver(signOutObserver)
    }
    
    func assignSwipeAction() {
        let upRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleUp))
        upRecognizer.direction = UISwipeGestureRecognizerDirection.up
        self.view?.addGestureRecognizer(upRecognizer)
        
        let downRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleDown))
        downRecognizer.direction = UISwipeGestureRecognizerDirection.down
        self.view?.addGestureRecognizer(downRecognizer)
        
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleLeft))
        leftRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(leftRecognizer)
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleRight))
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

    
    func presentSignInViewController() {
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            present(signInViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
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
    
    func sendImageMessage() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.addAttachmentData(UIImageJPEGRepresentation(imageView.image!, 1)!, typeIdentifier: "image/jpg", filename: "images.jpg")
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func shareImageWithFacebook() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            facebookSheet.add(imageView.image)
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
            twitterSheet.add(imageView.image)
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
            weiboSheet.add(imageView.image)
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
    
    //Photo button
    @IBAction func takePhoto(_ sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //Select from photo library
    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        imageView.contentMode = .scaleAspectFit //3
        imageView.image = chosenImage //4

        dismiss(animated:true, completion: nil) //5
    }
    
    
    //Take Another Photo
    @IBAction func takeAnotherPhoto(_ sender: AnyObject) {
        didPressTakeAnother()
        firstTime = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    
                    self.imageView.image = image
                }
            })
        }
        self.view.bringSubview(toFront: imageView)
        self.view.bringSubview(toFront: settingPageButton)
        self.view.bringSubview(toFront: takeAnotherButton)
        
            self.view.bringSubview(toFront: userSettingsButton)

    }
    
    var didTakePhoto = Bool()
    //This will take a photo and toggle if we can take another photo
    func didPressTakeAnother(){
        if didTakePhoto == true{
            didTakePhoto = false
            self.view.sendSubview(toBack: imageView)
            self.view.sendSubview(toBack: takeAnotherButton)
            self.view.sendSubview(toBack: settingPageButton)
            self.view.sendSubview(toBack: userSettingsButton)
        }
        else{
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
        
    }
    
    // Might need to change this part.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            if firstTime {
                didPressTakeAnother()
                firstTime = false
            }
            
        }
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func sendToUserSettings(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "UserSettings", bundle: nil)
        let userSettingsViewController = storyboard.instantiateViewController(withIdentifier: "UserSettings") as! UserSettingsViewController
        present(userSettingsViewController, animated: true, completion: nil)
     //   let viewController = storyboard?.instantiateViewController(withIdentifier: demoFeature.storyboard)
       //   self.navigationController!.pushViewController(viewController!, animated: true)
    }
    
    
}

