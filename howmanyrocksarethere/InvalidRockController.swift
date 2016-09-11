//
//  InValidRockController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import CoreLocation

class InValidRockController: UIViewController {

  var imageUrl : String!
  var location : CLLocationCoordinate2D?
  let locationManager = CLLocationManager()

  lazy var imageView : UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "invalid"))
    imageView.contentMode = .ScaleAspectFit
    return imageView
  }()

  lazy var label : UILabel = {
    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 20)
    label.textColor = Constants.Color.White
    label.textAlignment = .Center
    label.text = "THIS IS NOT A ROCK."
    label.numberOfLines = 3

    return label
  }()

  lazy var cancelButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.enabled = false
    button.backgroundColor = Constants.Color.White
    button.setTitle("CANCEL", forState: .Normal)
    button.setTitleColor(Constants.Color.BackgroundColor, forState: .Normal)
    button.addTarget(self, action: #selector(shouldCancel), forControlEvents: .TouchUpInside)

    return button
  }()

  lazy var continueButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.enabled = false
    button.backgroundColor = Constants.Color.TintColor
    button.setTitle("CONTINUE", forState: .Normal)
    button.titleLabel?.textColor = Constants.Color.White
    button.addTarget(self, action: #selector(shouldContinue), forControlEvents: .TouchUpInside)

    return button
  }()

  convenience init(url: String) {
    self.init(nibName: nil, bundle: nil)

    self.imageUrl = url
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.BackgroundColor

    view.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.centerX.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.7)
      make.height.equalTo(imageView.snp_width)
      make.centerY.equalTo(view).offset(-40)
    }


    view.addSubview(label)
    label.snp_makeConstraints { make in
      make.top.equalTo(imageView.snp_bottom)
      make.centerX.equalTo(view)
      make.height.equalTo(50)
      make.width.equalTo(view).multipliedBy(0.8)
    }

    view.addSubview(cancelButton)
    cancelButton.snp_makeConstraints { make in
      make.left.bottom.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.5)
      make.height.equalTo(70)
    }

    view.addSubview(continueButton)
    continueButton.snp_makeConstraints { make in
      make.bottom.right.equalTo(view)
      make.left.equalTo(cancelButton.snp_right)
      make.height.equalTo(cancelButton)
    }

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.requestWhenInUseAuthorization()

    self.submitRock()
  }

  func submitRock() {
    // @TODO(shrugs) start a loading indicator
    // start request to submit the rock
    // exit loading indicator
    // trigger delegate close method

    let params : [String: AnyObject] = [
      "lat": self.location?.latitude ?? 40.739415,
      "lng": self.location?.longitude ?? -73.989686,
      "image": imageUrl,
      "nickname": "Not a rock",
      "comment": "Probably not a rock."
    ]

    THE_DATABASE.sharedDatabase.submitNotRock(params) { [weak self] in
      self?.continueButton.enabled = true
      self?.cancelButton.enabled = true
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    locationManager.stopUpdatingLocation()
  }

  func shouldCancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func shouldContinue() {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://howmanythingsarenot.rocks")!)
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

extension InValidRockController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    locationManager.startUpdatingLocation()
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let loc = locations.first {
      self.location = loc.coordinate
    }
  }
}































