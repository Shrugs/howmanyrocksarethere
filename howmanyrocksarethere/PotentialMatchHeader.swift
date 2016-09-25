//
//  UniqueRockButton.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

class PotentialMatchHeader: UICollectionReusableView {

  lazy var label : UILabel = {
    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 20)
    label.textColor = Constants.Color.White
    label.textAlignment = .Center
    label.text = "FINDING ROCKS NEAR YOU..."
    label.numberOfLines = 2
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(label)
    label.snp_makeConstraints { make in
      make.center.height.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.8)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
