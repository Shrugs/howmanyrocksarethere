//
//  ValidRockController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

class ValidRockController: UIViewController {

  lazy var imageView : UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "verified"))
    imageView.contentMode = .ScaleAspectFit
    return imageView
  }()

  lazy var label : UILabel = {
    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 20)
    label.textColor = Constants.Color.White
    label.textAlignment = .Center
    label.text = "CONGRATS! IT LOOKS LIKE YOU FOUND A ROCK."
    label.numberOfLines = 3

    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.BackgroundColor

    view.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.centerX.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.7)
      make.height.equalTo(imageView.snp_width)
      make.centerY.equalTo(view).offset(-40)
    }


    view.addSubview(label)
    label.snp_makeConstraints { make in
      make.top.equalTo(imageView.snp_bottom)
      make.centerX.equalTo(view)
      make.height.equalTo(50)
      make.width.equalTo(view).multipliedBy(0.8)
    }

  }
}






























