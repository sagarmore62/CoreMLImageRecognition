//
//  ImageConverter.h
//  CoreMLImageRecognition
//
//  Created by Sagar More on 02/05/18.
//  Copyright © 2018 Sagar More. All rights reserved.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageConverter : NSObject

+ (CVPixelBufferRef) pixelBufferFromImage: (CGImageRef) image;

@end
