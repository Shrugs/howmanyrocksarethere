//
//  IsThisARockController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

/**
 
 Given an image, send a request to clarifai to determine whether or not the image is of a rock.
 
 Show a loading indicator while the request is in progress.

*/
class IsThisARockController : UIViewController {

  var image : UIImage!

  convenience init(image: UIImage) {
    self.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
}
