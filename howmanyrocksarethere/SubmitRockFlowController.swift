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

  func setupFusuma() {
    Fusuma.fusumaTintColor = Constants.Color.TintColor
    Fusuma.fusumaCheckImage = UIImage(named: "ic_navigate_next", inBundle: nil, compatibleWithTraitCollection: nil)
  }

  func showCamera() {
    setupFusuma()
    let camera = FusumaViewController()
    camera.delegate = self
    self.pushViewController(camera, animated: true)
  }

  func showProfile(rock: [String: AnyObject]) {
    let profile = RockProfileController(rock: rock)
    self.pushViewController(profile, animated: true)
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
    // @TODO(shrugs) move to the next view with UIImage
    let submitPostController = SubmitRockPostController(image: image)
    submitPostController.delegate = self
    self.pushViewController(submitPostController, animated: true)
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