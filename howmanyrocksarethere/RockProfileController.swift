//
//  RockProfileController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import PKHUD

protocol RockProfileControllerDelegate {
  func shouldClose()
}

class RockProfileController: UIViewController {

  var delegate : RockProfileControllerDelegate?

  let profile = RockProfile()
  var rock : Rock!

  let container = UIScrollView()
  let content = UIView()

  var price = 0.40

  lazy var claimButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.titleLabel?.font = UIFont(name: Constants.Text.BoldFont.Name, size: Constants.Text.BoldFont.Size)
    button.setTitle("Discover Rock ($0.99)", forState: .Normal)
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

  convenience init(rock: Rock) {
    self.init(nibName: nil, bundle: nil)

    self.rock = rock
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setOwnsRock()

    self.updateRock()

    view.backgroundColor = Constants.Color.AltBackground

    view.addSubview(container)
    container.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }

    container.addSubview(content)
    content.snp_makeConstraints { make in
      make.edges.equalTo(container)
      make.width.equalTo(view)
      make.height.equalTo(view)
    }

    profile.setRock(self.rock)
    content.addSubview(profile)
    profile.snp_makeConstraints { make in
      make.top.left.right.equalTo(content)
      make.height.equalTo(content.snp_width).multipliedBy(1.60)
    }

    content.addSubview(claimButton)
    claimButton.snp_makeConstraints { make in
      make.top.equalTo(profile.snp_bottom)
      make.left.right.equalTo(content)
      make.height.equalTo(70)
    }

    view.addSubview(closeButton)
    closeButton.snp_makeConstraints { make in
      make.top.equalTo(view).offset(5)
      make.left.equalTo(view).offset(5)
      make.width.height.equalTo(40)
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  func close() {
    delegate?.shouldClose()
  }

  func updateRock() {
    if let _id = self.rock["_id"] as? String {
      THE_DATABASE.sharedDatabase.getRock(_id) { rock in
        self.rock = rock
        self.setOwnsRock()
        self.profile.setRock(rock)
      }
    }
  }

  func setOwnsRock() {
    if let currentUser = THE_DATABASE.sharedDatabase.currentUser {
      if let ownerId = self.rock["owner_id"] as? String
        where ownerId == currentUser["_id"] {

        self.claimButton.setTitle("You Discovered This Rock", forState: .Normal)
        self.claimButton.enabled = false
      } else {
        self.claimButton.setTitle("Discover Rock ($0.99)", forState: .Normal)
        self.claimButton.enabled = true
      }
    }
  }

  func discover() {
    HUD.show(.Progress)

    SwiftyStoreKit.purchaseProduct("mat.tc.howmanyrocks.DiscoverRock") { result in
      switch result {
      case .Success(_):
        HUD.flash(.Success, delay: 0.5)
        // save discoverer on the backend
        THE_DATABASE.sharedDatabase.discoverRock(self.rock["_id"] as! String) { [weak self] rock in
          self?.rock = rock
          self?.setOwnsRock()
          self?.profile.setRock(rock)
        }
      case .Error(let error):
        HUD.flash(.Error, delay: 0.5)
        self.alert(
          title: "Something went wrong.",
          message: "Help us count how many errors they are, and where are they by reporting this error: '\(error)'",
          close: "OK"
        )
      }
    }
  }
}































