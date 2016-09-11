//
//  Utils.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import Foundation

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
  return "https://s3.amazonaws.com/\(AWS.S3.BucketName)/\(key)"
}