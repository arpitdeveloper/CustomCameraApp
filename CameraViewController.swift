//
//  CameraViewController.swift
//  CustomCamera
//
//  Created by Ankit Nigam on 25/11/17.
//  Copyright © 2017 SumitJagdev. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

class CameraViewController: UIViewController {

    @IBOutlet var cameraView : UIView!
    @IBOutlet var overLapImageView : UIImageView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var capturePhotoOutput: AVCaptureStillImageOutput?
    
    var imageNumber : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let str = String(format: "Image-%d", imageNumber)
        if let image = UIImage(named: str) {
            overLapImageView.image = image
            print("Image Found")
        }
        
        self.drawCameraLayer()
        
        AppUtility.lockOrientation(.portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawCameraLayer() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            //Output
            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCaptureStillImageOutput()
            capturePhotoOutput?.isHighResolutionStillImageOutputEnabled = true
            
//            capturePhotoOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG, AVVideoWidthKey : NSNumber(integerLiteral: 100), AVVideoHeightKey : NSNumber(integerLiteral: 100)]
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput)
            
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = self.cameraView.layer.bounds
            self.cameraView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print(error)
        }
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if videoPreviewLayer != nil {
            videoPreviewLayer?.frame = self.cameraView.layer.bounds
        }
        
    }

    @IBAction func captureCameraImageButtonTapped(_ sender: UIButton){
        
        if let videoConnection = capturePhotoOutput?.connection(withMediaType: AVMediaTypeVideo){
            capturePhotoOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer:CMSampleBuffer?, error: Error?) -> Void in
                
                if CMGetAttachment(buffer!, kCGImagePropertyExifDictionary, nil) != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
//                    self.overLapImageView.image = UIImage(data: imageData!)
                    let img = UIImage(data: imageData!)
//                    self.overLapImageView.image = self.cropToPreviewLayer(originalImage: img!)
                    let croppedImage = self.cropToPreviewLayer(originalImage: img!)
                    UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
                }
            })
        }
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: UIButton){
        
    }

    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage {
        let outputRect = videoPreviewLayer?.metadataOutputRectOfInterest(for: (videoPreviewLayer?.bounds)!)
        var cgImage = originalImage.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: (outputRect?.origin.x)! * width, y: (outputRect?.origin.y)! * height, width: (outputRect?.size.width)! * width, height: (outputRect?.size.height)! * height)
        
        cgImage = cgImage.cropping(to: cropRect)!
        let scaleValue = UIScreen.main.scale + 1
        let croppedUIImage = UIImage(cgImage: cgImage, scale: scaleValue, orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
    
    
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}
