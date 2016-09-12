//
//  PotentialMatch.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

protocol PotentialMatchDelegate {
  func didSelectPotentialMatch(rock: [String: AnyObject])
}

class PotentialMatch: UICollectionViewCell {

  var delegate : PotentialMatchDelegate?

  let profile = RockProfile()

  var myRock : [String: AnyObject]?

  lazy var myRockButton : UIButton = {
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.titleLabel?.font = UIFont(name: Constants.Text.BoldFont.Name, size: Constants.Text.BoldFont.Size)
    button.setTitle("YES", forState: .Normal)
    button.setTitleColor(Constants.Color.White, forState: .Normal)
    button.addTarget(self, action: #selector(chooseRock), forControlEvents: .TouchUpInside)
    return button
  }()

  lazy var label : UILabel = {
    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 20)
    label.textColor = Constants.Color.BackgroundColor
    label.textAlignment = .Center
    label.text = "IS THIS YOUR ROCK?"
    label.numberOfLines = 2
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = Constants.Color.AltBackground

    // display the profile, but a button instead of the informations
    self.addSubview(profile)
    profile.snp_makeConstraints { make in
      make.top.left.right.equalTo(self)
      make.height.equalTo(self.snp_width).multipliedBy(1.60)
    }

    self.addSubview(label)
    label.snp_makeConstraints { make in
      make.top.equalTo(profile.snp_bottom)
      make.centerX.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.8)
      make.height.equalTo(60)
    }

    self.addSubview(myRockButton)
    myRockButton.snp_makeConstraints { make in
      make.top.equalTo(label.snp_bottom)
      make.centerX.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.8)
      make.height.equalTo(50)
    }
  }

  func chooseRock() {
    if let rock = self.myRock {
      delegate?.didSelectPotentialMatch(rock)
    }
  }

  func setRock(rock: [String: AnyObject]) {
    self.myRock = rock
    profile.setRock(rock)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
