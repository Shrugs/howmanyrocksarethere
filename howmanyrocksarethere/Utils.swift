//
//  Utils.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

func randomAlphaNumericString(length: Int) -> String {

  let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  let allowedCharsCount = UInt32(allowedChars.characters.count)
  var randomString = ""

  for _ in (0..<length) {
    let randomNum = Int(arc4random_uniform(allowedCharsCount))
    let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
    randomString += String(newCharacter)
  }

  return randomString
}

func s3Url(key: String) -> String {
  return "https://\(AWS.S3.BucketName).s3.amazonaws.com/\(key)"
}

func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
  let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
  let imageRef = image.CGImage

  UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
  let context = UIGraphicsGetCurrentContext()

  // Set the quality level to use when rescaling
  CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
  let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)

  CGContextConcatCTM(context, flipVertical)
  // Draw into the context; this scales the image
  CGContextDrawImage(context, newRect, imageRef)

  let newImageRef = CGBitmapContextCreateImage(context)! as CGImage
  let newImage = UIImage(CGImage: newImageRef)

  // Get the resized image from the context and a UIImage
  UIGraphicsEndImageContext()

  return newImage
}