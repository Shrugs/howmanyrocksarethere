//
//  LoadingController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

class LoadingController: UIViewController {

  lazy var loader : UIView = {
    let view = UIView()
    view.backgroundColor = Constants.Color.TintColor.colorWithAlphaComponent(0.8)
    return view
  }()

  lazy var imageView : UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.image = UIImage.gifWithName("loading")
    return imageView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .blackColor()

    view.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.center.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.6)
      make.height.equalTo(imageView.snp_width)
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}