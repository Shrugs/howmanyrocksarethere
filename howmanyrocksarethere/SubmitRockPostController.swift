//
//  NewRockPostController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import TextFieldEffects
import CoreLocation

let TEXT_FIELD_OFFSET = 10
let TEXT_FIELD_HEIGHT = 60

protocol SubmitRockPostControllerDelegate {
  func didFinish()
}

class SubmitRockPostController : UIViewController {

  var isFirstRun = true

  var image : UIImage!
  lazy var nicknameField : UITextField = { [unowned self] in
    return self.newTextField("Nick Name *")
  }()
  lazy var notesField : UITextField = { [unowned self] in
    return self.newTextField("Notes *")
  }()
  let container = UIScrollView()
  let content = UIView()

  var location : CLLocationCoordinate2D?

  let locationManager = CLLocationManager()

  let requiredFields : UILabel = {
    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 24)
    label.textColor = Constants.Color.BackgroundColor
    label.textAlignment = .Center
    label.text = "* Required Fields"
    return label
  }()

  lazy var continueButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.setTitle("CONTINUE", forState: .Normal)
    button.titleLabel?.textColor = Constants.Color.White
    button.backgroundColor = Constants.Color.TintColor
    button.addTarget(self, action: #selector(submitRock), forControlEvents: .TouchUpInside)
    return button
  }()

  var delegate : SubmitRockPostControllerDelegate?

  var imageUrl : String!

  convenience init(image: UIImage, url: String) {
    self.init(nibName: nil, bundle: nil)

    self.image = image
    self.imageUrl = url
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.requestWhenInUseAuthorization()

    setupDismissHandler()

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

    let imageView = UIImageView(image: image)
    content.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.top.left.right.equalTo(content)
      make.height.equalTo(content.snp_width)
    }

    content.addSubview(nicknameField)
    nicknameField.snp_makeConstraints { make in
      make.top.equalTo(imageView.snp_bottom).offset(TEXT_FIELD_OFFSET)
      make.left.right.equalTo(content)
      make.height.equalTo(TEXT_FIELD_HEIGHT)
    }

    content.addSubview(notesField)
    notesField.snp_makeConstraints { make in
      make.top.equalTo(nicknameField.snp_bottom).offset(TEXT_FIELD_OFFSET)
      make.left.right.equalTo(content)
      make.height.equalTo(TEXT_FIELD_HEIGHT)
    }

    content.addSubview(continueButton)
    continueButton.snp_makeConstraints { make in
      make.left.right.bottom.equalTo(content)
      make.height.equalTo(70)
    }

    content.addSubview(requiredFields)
    requiredFields.snp_makeConstraints { make in
      make.top.equalTo(notesField.snp_bottom).offset(5)
      make.left.right.equalTo(content)
      make.bottom.equalTo(continueButton.snp_top)
    }
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
      "nickname": self.nicknameField.text ?? "",
      "comment": self.notesField.text ?? ""
    ]

    THE_DATABASE.sharedDatabase.submitRock(params) { [weak self] in
      // assume success
      // @TODO(shrugs) remove loading view here
      self?.dismissViewControllerAnimated(false) {
        self?.delegate?.didFinish()
      }
    }

  }

  func setupDismissHandler() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }

  func dismissKeyboard() {
    nicknameField.resignFirstResponder()
    notesField.resignFirstResponder()
  }

  func keyboardWasShown(notification: NSNotification) {
    let info = notification.userInfo!
    let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size

    let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
    container.contentInset = contentInsets
    container.scrollIndicatorInsets = contentInsets
  }

  func keyboardWillHide() {
    container.contentInset = UIEdgeInsetsZero
    container.scrollIndicatorInsets = UIEdgeInsetsZero
  }

  func listenToKeyboard() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
  }

  func unlistenToKeyboard() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewWillDisappear(animated: Bool) {
    unlistenToKeyboard()
    locationManager.stopUpdatingLocation()
  }

  override func viewWillAppear(animated: Bool) {
    listenToKeyboard()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if (isFirstRun) {
      isFirstRun = false

      presentViewController(ValidRockController(), animated: false, completion: nil)
      NSTimer.schedule(delay: 5.0) { [weak self] timer in
        self?.dismissViewControllerAnimated(true, completion: nil)
      }
    }
    
  }

  func newTextField(placeholder: String) -> YokoTextField {
    let textField = YokoTextField()
    textField.placeholderColor = Constants.Color.BackgroundColor
    textField.foregroundColor = Constants.Color.BackgroundColor
    textField.placeholder = placeholder
    textField.textColor = Constants.Color.White

    return textField
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

extension SubmitRockPostController : CLLocationManagerDelegate {

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    locationManager.startUpdatingLocation()
  }
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let loc = locations.first {
      self.location = loc.coordinate
    }
  }
}





























