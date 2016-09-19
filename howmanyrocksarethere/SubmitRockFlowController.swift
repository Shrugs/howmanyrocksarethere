//
//  SubmitRockController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import Fusuma

protocol SubmitRockFlowControllerDelegate {
  func shouldClose()
}

class SubmitRockFlowController: UINavigationController {

  var cDelegate: SubmitRockFlowControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setNavigationBarHidden(true, animated: false)

    let firstView = PotentialMatchCollectionView()
    firstView.delegate = self

    self.viewControllers = [
      firstView
    ]
  }

  func showCamera() {
    let camera = FusumaViewController()
    camera.availableModes = [.Camera]
    camera.tintColor = Constants.Color.TintColor
    camera.checkImage = UIImage(named: "ic_navigate_next", inBundle: nil, compatibleWithTraitCollection: nil)
    camera.delegate = self
    self.pushViewController(camera, animated: true)
  }

  func showProfile(rock: [String: AnyObject]) {
    let profile = RockProfileController(rock: rock)
    profile.delegate = self
    self.pushViewController(profile, animated: true)
  }
}

extension SubmitRockFlowController : IsThisARockControllerDelegate {
  func isRock(image: UIImage, url: String) {
    // if this is a rock, post it
    let submitPostController = SubmitRockPostController(image: image, url: url)
    submitPostController.delegate = self
    self.pushViewController(submitPostController, animated: false)
  }

  func isNotRock(image: UIImage, url: String) {
    self.pushViewController(InValidRockController(url: url), animated: true)
  }
}

extension SubmitRockFlowController : RockProfileControllerDelegate {
  func shouldClose() {
    cDelegate?.shouldClose()
  }
}

extension SubmitRockFlowController : PotentialMatchCollectionDelegate {
  func didSelectPotentialMatch(rock: [String: AnyObject]) {
    // show profile for rock
    showProfile(rock)
  }
  func didChooseUniqueRock() {
    // show fusuma
    showCamera()
  }
}

extension SubmitRockFlowController : FusumaDelegate {
  func fusuma(fusuma: FusumaViewController, imageSelected image: UIImage, viaMode mode: Int) {
    if mode == FusumaMode.Camera.rawValue {
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    // determine if is rock
    let isRockController = IsThisARockController(image: image)
    isRockController.delegate = self
    self.pushViewController(isRockController, animated: true)
  }

  func fusumaClosed(fusuma: FusumaViewController) {
    self.cDelegate?.shouldClose()
  }

  func fusumaCameraRollUnauthorized(fusuma: FusumaViewController) {
    let alert = UIAlertController(
      title: "Access Requested",
      message: "Saving image needs to access your photo album",
      preferredStyle: .Alert
    )

    alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
      }
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
    }))

    self.presentViewController(alert, animated: true, completion: nil)
  }

  func fusuma(fusuma: FusumaViewController, videoCompletedWithFileURL fileURL: NSURL) {
    // don't do anything cause I don't use videos (yet!)
  }
}

extension SubmitRockFlowController : SubmitRockPostControllerDelegate {
  func didFinish() {
    self.cDelegate?.shouldClose()
  }
}