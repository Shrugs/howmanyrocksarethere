//
//  Constants.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

struct Constants {

  struct Text {
    struct Font {
      static var Size : CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 22 : 30
      static var Name = "AvenirNext-UltraLight"
      static var Color = UIColor.whiteColor()
    }
    struct BoldFont {
      static var Size : CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 22 : 30
      static var Name = "AvenirNext-DemiBold"
      static var Color = UIColor.whiteColor()
    }
    struct TitleFont {
      static var Size : CGFloat = 15
      static var Name = "AvenirNext-DemiBold"
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
    static var Base = "http://9403e8f8.ngrok.io"
    static var Upload = "/api/photo/upload"
  }
  
}




