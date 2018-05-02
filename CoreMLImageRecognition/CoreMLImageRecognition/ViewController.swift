//
//  ViewController.swift
//  CoreMLImageRecognition
//
//  Created by Sagar More on 02/05/18.
//  Copyright © 2018 Sagar More. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var viewVideoPreview : VideoPreviewView!
    @IBOutlet weak var lblResult : UILabel!
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "video session queue")
    private var permissionStatus = false
    
    let modelInputSize = CGSize(width: 224, height: 224)
    let model = GoogLeNetPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set video preview view
        viewVideoPreview.videoPreviewView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        viewVideoPreview.session = session
        
        // Check for permissions
        checkPermission()
        
        // Configure Session in session queue
        sessionQueue.async { [unowned self] in
            self.configuration()
        }
        
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] (result) in
            self.permissionStatus = result
            self.sessionQueue.resume()
        }
    }
    
    private func checkPermission() {
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionStatus = true
        case .notDetermined:
            requestPermission()
        default:
            permissionStatus = false
        }
    }

    private func configuration() {
        guard permissionStatus else {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back) else {
            return
        }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        guard session.canAddInput(captureDeviceInput) else {
            return
        }
        session.addInput(captureDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video sample buffer"))
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        guard session.canAddOutput(videoOutput) else { return }
        session.addOutput(videoOutput)
        
        session.commitConfiguration()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        self.session.startRunning()
        self.isSessionRunning = self.session.isRunning
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        sessionQueue.async { [unowned self] in
//            if self.permissionStatus {
//                self.session.startRunning()
//                self.isSessionRunning = self.session.isRunning
//           }
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        sessionQueue.async { [unowned self] in
//            if self.permissionStatus {
//                self.session.stopRunning()
//                self.isSessionRunning = self.session.isRunning
//            }
//        }
//    }

}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        guard let uiImage = UIImage(ciImage: ciImage).resize(modelInputSize),
            let cgImage = uiImage.cgImage,
            let pixelBuffer = ImageConverter.pixelBuffer(from: cgImage)?.takeRetainedValue() else {
                return
        }
        
        let input = GoogLeNetPlacesInput.init(sceneImage: pixelBuffer)
        do {
            if let output = try? model.prediction(input: input) {
                DispatchQueue.main.async {
                    self.lblResult.text = output.sceneLabel
                }
            }
        }
        
       
    }
    
}

extension UIImage {
    func resize(_ size: CGSize)-> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

