//
//  VideoPreviewView.swift
//  CoreMLImageRecognition
//
//  Created by Sagar More on 02/05/18.
//  Copyright © 2018 Sagar More. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewView : UIView {
    
    var videoPreviewView : AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session : AVCaptureSession? {
        get {
            return videoPreviewView.session
        } set {
            videoPreviewView.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
