//
//  FeedItem.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

let ownerHeight = 60.0

class FeedItem : UICollectionViewCell {

  let profile = RockProfile()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(profile)
    profile.snp_makeConstraints { make in
      make.edges.equalTo(self)
    }
  }

  func setRock(rock: [String: AnyObject]) {
    profile.setRock(rock)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

