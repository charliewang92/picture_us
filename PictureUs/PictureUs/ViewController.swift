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




class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    let picker = UIImagePickerController()
    var phoneNumber: String!
    var neginPhone: String!
    var tingtingPhone: String!
    
    
    @IBOutlet var cameraView: UIView!
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet var buttonStack: UIStackView!
    var firstTime: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
         picker.delegate = self
         phoneNumber = ""
         neginPhone = ""
         tingtingPhone = ""
        self.view.bringSubview(toFront: imageView)
        testAction()
    }
    
    func testAction() {
        let upRecognizer = UISwipeGestureRecognizer(target: self, action: "handleUp")
        upRecognizer.direction = UISwipeGestureRecognizerDirection.up
        self.view?.addGestureRecognizer(upRecognizer)
        
        let downRecognizer = UISwipeGestureRecognizer(target: self, action: "handleDown")
        downRecognizer.direction = UISwipeGestureRecognizerDirection.down
        self.view?.addGestureRecognizer(downRecognizer)
        
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: "handleLeft")
        leftRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(leftRecognizer)
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: "handleRight")
        rightRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(rightRecognizer)
        
        
    }
    func handleRight() {
        testFbPush()
    }
    
    func handleLeft() {
        testTwitterPush()
    }
    
    func handleDown() {
        testSendText()
    }
    
    func handleUp() {
        testWeiboPush()
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
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
    
    //Sends text to the phone numbers selected
    @IBAction func sendText(_ sender: AnyObject) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.addAttachmentData(UIImageJPEGRepresentation(imageView.image!, 1)!, typeIdentifier: "image/jpg", filename: "images.jpg")
            controller.recipients = [phoneNumber, tingtingPhone, neginPhone]
            controller.messageComposeDelegate = self
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func testSendText() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.addAttachmentData(UIImageJPEGRepresentation(imageView.image!, 1)!, typeIdentifier: "image/jpg", filename: "images.jpg")
            controller.recipients = [phoneNumber, tingtingPhone, neginPhone]
            controller.messageComposeDelegate = self
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func testFbPush() {
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
    
    func testTwitterPush() {
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
    
    func testWeiboPush() {
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
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        imageView.contentMode = .scaleAspectFit //3
        imageView.image = chosenImage //4

        dismiss(animated:true, completion: nil) //5
    }
    
    
    //Twitter share
    @IBAction func twitterPush(_ sender: AnyObject) {
        didPressTakeAnother()
        firstTime = true
        print("clickd on send")
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
//            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//            twitterSheet.setInitialText("Share on Twitter")
//            twitterSheet.add(imageView.image)
//            self.present(twitterSheet, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    
    //FB share
    @IBAction func facebookPush(_ sender: AnyObject) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didPressTakePhoto(){
        self.view.bringSubview(toFront: buttonStack)
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
                (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider  = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent )
//                    kCGRenderingIntentDefault
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    self.cameraView.isHidden = true
                }
            })
        }
        
        
    }
    
    var didTakePhoto = Bool()
    //This will take a photo and toggle if we can take another photo
    func didPressTakeAnother(){
        if didTakePhoto == true{
            imageView.isHidden = true
            cameraView.isHidden = false
            didTakePhoto = false
            self.view.sendSubview(toBack: buttonStack)
            
        }
        else{
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
            
        }
        
    }
    
//    @IBAction func TogglePhoto(_ sender: AnyObject) {
//            didPressTakeAnother()
//    }
    
    // Might need to change this part.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if firstTime {
                didPressTakeAnother()
                firstTime = false
            }
            
        }
        super.touchesBegan(touches, with: event)
    }

    
    
}

