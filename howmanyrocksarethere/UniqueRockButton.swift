//
//  UniqueRockButton.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

protocol UniqueRockButtonDelegate {
  func didSelectUniqueRock()
}

class UniqueRockButton: UICollectionReusableView {

  var delegate : UniqueRockButtonDelegate?

  lazy var button : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.setTitle("MY ROCK IS UNIQUE", forState: .Normal)
    button.titleLabel?.textColor = Constants.Color.White
    button.addTarget(self, action: #selector(selectThing), forControlEvents: .TouchUpInside)
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(button)
    button.snp_makeConstraints { make in
      make.edges.equalTo(self)
    }
  }

  func selectThing() {
    delegate?.didSelectUniqueRock()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
