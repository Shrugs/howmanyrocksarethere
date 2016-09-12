//
//  RockProfileController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

protocol RockProfileControllerDelegate {
  func shouldClose()
}

class RockProfileController: UIViewController {

  var delegate : RockProfileControllerDelegate?

  let profile = RockProfile()
  var rock : [String: AnyObject]!

  var price = 0.40

  lazy var claimButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.titleLabel?.font = UIFont(name: Constants.Text.BoldFont.Name, size: Constants.Text.BoldFont.Size)
    button.setTitle("Discover Rock ($0.40)", forState: .Normal)
    button.titleLabel?.textColor = Constants.Color.White
    button.addTarget(self, action: #selector(discover), forControlEvents: .TouchUpInside)
    return button
  }()

  lazy var closeButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.setImage(UIImage(named: "ic_close"), forState: .Normal)
    button.addTarget(self, action: #selector(close), forControlEvents: .TouchUpInside)
    return button
  }()

  convenience init(rock: [String: AnyObject]) {
    self.init(nibName: nil, bundle: nil)

    self.rock = rock
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.AltBackground

    profile.setRock(self.rock)
    view.addSubview(profile)
    profile.snp_makeConstraints { make in
      make.top.left.right.equalTo(view)
      make.height.equalTo(view.snp_width).multipliedBy(1.60)
    }

    view.addSubview(claimButton)
    claimButton.snp_makeConstraints { make in
      make.top.equalTo(profile.snp_bottom)
      make.left.right.equalTo(view)
      make.bottom.equalTo(view)
    }

    view.addSubview(closeButton)
    closeButton.snp_makeConstraints { make in
      make.top.equalTo(profile).offset(5)
      make.left.equalTo(profile).offset(5)
      make.width.height.equalTo(40)
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  func close() {
    delegate?.shouldClose()
  }

  func discover() {
    // launch venmo and then trigger update (assume success)
    let id = String(self.rock["id"] as? Int ?? 1)

    UIApplication
      .sharedApplication()
      .openURL(NSURL(string: "venmosdk://venmo.com/?amount=\(self.price)&recipients=alecc&note=Discover%20rock%20%230000\(id)%3F")!)

    // save discoverer on the backend
    THE_DATABASE.sharedDatabase.discoverRock(rock["_id"] as! String) { [weak self] rock in
      self?.claimButton.setTitle("Discover Rock ($0.80)", forState: .Normal)
      self?.rock = rock
      self?.profile.setRock(rock)
    }
  }
}































