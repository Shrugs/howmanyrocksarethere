//
//  Constants.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

struct Constants {

  struct Clarifai {
    static var ClientId = "0NARCHSIJivBGpqAQyx45AlAaFNAlGndxGDbkNra"
    static var ClientSecret = "t418vHcAf50jMfU2ST95yWH_7t7FVz1w9RVVeip4"
  }

  struct Text {
    struct Font {
      static var Size : CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 22 : 30
      static var Name = "Courier"
      static var Color = UIColor.whiteColor()
    }
    struct BoldFont {
      static var Size : CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 22 : 30
      static var Name = "Courier-Bold"
      static var Color = UIColor.whiteColor()
    }
    struct TitleFont {
      static var Size : CGFloat = 15
      static var Name = "Courier-Bold"
      static var Color = UIColor.whiteColor()
    }
  }

  struct Color {
    static var BackgroundColor = UIColor(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    static var TintColor = UIColor(red: 68.0/255.0, green: 230.0/255.0, blue: 112.0/255.0, alpha: 1.0)
    static var AltBackground = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    static var White = UIColor.whiteColor()
    static var OffWhite = UIColor.whiteColor().colorWithAlphaComponent(0.7)

    static var Facebook = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 1.0)
    static var Twitter = UIColor(red: 0.0, green: 172.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    static var Instagram = UIColor(red: 81.0/255.0, green: 127.0/255.0, blue: 164.0/255.0, alpha: 1.0)
  }

  struct Urls {
    // static var Base = "http://howmanyrocks.herokuapp.com"
    static var Base = "http://9c95b5fb.ngrok.io"
  }
  
}




