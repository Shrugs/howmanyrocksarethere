//
//  FeedHeader.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

class FeedHeader: UICollectionReusableView {

  lazy var titleLabel : UILabel = {
    let label = UILabel()

    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 30)
    label.textColor = Constants.Color.White
    label.textAlignment = .Center

    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = Constants.Color.BackgroundColor

    self.addSubview(titleLabel)
    titleLabel.snp_makeConstraints { make in
      make.left.right.centerY.equalTo(self)
    }

    let tap = UITapGestureRecognizer(target: self, action: #selector(resetDefaults))
    tap.numberOfTapsRequired = 2
    self.addGestureRecognizer(tap)
  }

  func resetDefaults() {
    let defaults = NSUserDefaults.standardUserDefaults()
    for key in defaults.dictionaryRepresentation().keys {
      defaults.removeObjectForKey(key)
    }
    defaults.synchronize()
    
    exit(0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
