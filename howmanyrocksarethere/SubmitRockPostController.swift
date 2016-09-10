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

    let imageView = UIImageView(image: image)
    view.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.top.left.right.equalTo(view)
      make.height.equalTo(view.snp_width)
    }

  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
