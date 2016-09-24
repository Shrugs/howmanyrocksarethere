//
//  ViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UITabBarController {

  let statusBarBackground : UIView = {
    let view = UIView()
    view.backgroundColor = Constants.Color.BackgroundColor
    return view
  }()

  let feed = FeedViewController()
  lazy var map: UINavigationController = {
    let map = RockMapViewController()
    let navigationController = UINavigationController(rootViewController: map)
    navigationController.setNavigationBarHidden(true, animated: false)

    return navigationController
  }()


  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.BackgroundColor

    setViewControllers([
      feed,
      map
    ], animated: false)

    selectedIndex = 0

  }

  override func viewDidAppear(animated: Bool) {
    // if this is the first launch, aka, token doesn't exist, ask for a username and create the user
    if THE_DATABASE.sharedDatabase.token == nil {
      let login = LoginViewController()
      login.delegate = self
      presentViewController(login, animated: true, completion: nil)
    }
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

extension ViewController : LoginViewControllerDelegate {
  func didFinish() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}



























