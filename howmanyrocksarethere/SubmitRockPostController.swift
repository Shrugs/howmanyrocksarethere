//
//  NewRockPostController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

protocol SubmitRockPostControllerDelegate {
  func didFinish()
}

class SubmitRockPostController : UIViewController {

  var image : UIImage!

  var delegate : SubmitRockPostControllerDelegate?

  convenience init(image: UIImage) {
    self.init(nibName: nil, bundle: nil)

    self.image = image
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
