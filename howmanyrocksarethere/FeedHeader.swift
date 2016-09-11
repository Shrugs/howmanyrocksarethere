//
//  FeedHeader.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

protocol FeedHeaderDelegate {
  func didTapNewRock()
}

class FeedHeader: UICollectionReusableView {

  var delegate : FeedHeaderDelegate?

  lazy var titleLabel : UILabel = {
    let label = UILabel()

    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 30)
    label.textColor = Constants.Color.White
    label.textAlignment = .Center

    return label
  }()

  lazy var newRockButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.setTitle("ADD NEW ROCK", forState: .Normal)
    button.titleLabel?.textColor = Constants.Color.White
    button.addTarget(self, action: #selector(addNewRock), forControlEvents: .TouchUpInside)
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = Constants.Color.BackgroundColor

    self.addSubview(titleLabel)
    titleLabel.snp_makeConstraints { make in
      make.top.equalTo(self).offset(20)
      make.left.right.equalTo(self)
      make.height.equalTo(50)
    }

    self.addSubview(newRockButton)
    newRockButton.snp_makeConstraints { make in
      make.top.equalTo(titleLabel.snp_bottom)
      make.bottom.left.right.equalTo(self)
    }

    let tap = UITapGestureRecognizer(target: self, action: #selector(resetDefaults))
    tap.numberOfTapsRequired = 3
    self.addGestureRecognizer(tap)
  }

  func addNewRock() {
    delegate?.didTapNewRock()
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
