//
//  UIViewController+Alert.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/24/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

extension UIViewController {
  func alert(title title: String, message: String, close: String) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .Alert
    )

    alert.addAction(UIAlertAction(title: close, style: .Default, handler: nil))

    self.presentViewController(alert, animated: true, completion: nil)
  }
}
