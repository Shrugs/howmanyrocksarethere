//
//  LoginViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import TextFieldEffects
import PermissionScope
import PKHUD
import SnapKit

protocol LoginViewControllerDelegate {
  func didFinish()
}

class LoginViewController: UIViewController {

  let pscope = PermissionScope()

  lazy var usernameField : UITextField = {
    let textField = YokoTextField()
    textField.autocorrectionType = .No
    textField.autocapitalizationType = .None
    textField.placeholderColor = Constants.Color.BackgroundColor
    textField.foregroundColor = Constants.Color.BackgroundColor
    textField.placeholder = "USERNAME *"
    textField.textColor = Constants.Color.White
    return textField
  }()

  lazy var loginButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.setTitle("Login", forState: .Normal)
    button.setTitleColor(Constants.Color.White, forState: .Normal)
    button.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
    return button
  }()

  lazy var banner : UIView = {
    let view = UIView()
    view.backgroundColor = Constants.Color.BackgroundColor

    let imageView = UIImageView(image: UIImage(named: "logo"))
    view.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.top.equalTo(view).offset(20)
      make.centerX.equalTo(view)
      make.height.equalTo(view).multipliedBy(0.7).priority(500)
      make.height.lessThanOrEqualTo(view.snp_width).multipliedBy(0.4)
      make.width.equalTo(imageView.snp_height)
    }

    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: 20)
    label.textColor = Constants.Color.White
    label.textAlignment = .Center
    label.text = "HOW MANY ROCKS ARE THERE"
    label.numberOfLines = 2

    view.addSubview(label)
    label.snp_makeConstraints { make in
      make.top.equalTo(imageView.snp_bottom).offset(10)
      make.centerX.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.6)
    }

    return view
  }()

  var delegate : LoginViewControllerDelegate?

  var bottomConstraint : Constraint!

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.AltBackground

    view.addSubview(banner)
    banner.snp_makeConstraints { make in
      make.top.left.right.equalTo(view)
    }

    view.addSubview(usernameField)
    usernameField.snp_makeConstraints { make in
      make.top.equalTo(banner.snp_bottom).offset(15)
      make.centerX.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.8)
      make.height.equalTo(70)
    }

    view.addSubview(loginButton)
    loginButton.snp_makeConstraints { make in
      make.left.right.equalTo(view)
      make.top.equalTo(usernameField.snp_bottom).offset(10)
      make.height.equalTo(50)
      bottomConstraint = make.bottom.equalTo(view).constraint
    }

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)

    // configure PermissionScope
    pscope.headerLabel.text = "But first..."
    pscope.headerLabel.font = UIFont(name: Constants.Text.BoldFont.Name, size: 16)
    pscope.bodyLabel.text = "How Many Rocks Are There\nneeds these permissions to function."
    pscope.bodyLabel.font = UIFont(name: Constants.Text.Font.Name, size: 14)
    pscope.bodyLabel.numberOfLines = 3
    pscope.closeButton.hidden = true
    pscope.buttonFont = UIFont(name: Constants.Text.Font.Name, size: 14)!
    pscope.authorizedButtonColor = Constants.Color.TintColor
    pscope.addPermission(LocationWhileInUsePermission(),
                         message: "To find rocks near you.")
    pscope.addPermission(CameraPermission(),
                         message: "To take pictures of rocks you find.")
    pscope.addPermission(PhotosPermission(),
                         message: "To save your rock pictures.")
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    NSNotificationCenter
      .defaultCenter()
      .addObserver(
        self,
        selector: #selector(keyboardShown),
        name: UIKeyboardDidShowNotification,
        object: nil
      )

    NSNotificationCenter
      .defaultCenter()
      .addObserver(
        self,
        selector: #selector(keyboardHidden),
        name: UIKeyboardDidHideNotification,
        object: nil
    )

    usernameField.becomeFirstResponder()
  }

  override func viewWillDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  func keyboardShown(notification: NSNotification) {
    let info  = notification.userInfo!
    let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!

    let rawFrame = value.CGRectValue
    let keyboardFrame = view.convertRect(rawFrame, fromView: nil)

    bottomConstraint.updateOffset(-1 * keyboardFrame.size.height)

    view.setNeedsLayout()

    UIView.animateWithDuration(0.3) {
      self.view.layoutIfNeeded()
    }
  }

  func keyboardHidden(notification: NSNotification) {
    bottomConstraint.updateOffset(0)

    view.setNeedsLayout()

    UIView.animateWithDuration(0.3) {
      self.view.layoutIfNeeded()
    }
  }

  func login() {

    HUD.show(.Progress)

    // verify valid username
    THE_DATABASE.sharedDatabase.isValidUsername(usernameField.text ?? "") { isValid in
      if (!isValid) {
        HUD.flash(.Error, delay: 0.5)
        // @TODO(shrugs) - add alert view here
        self.alert(title: "Invalid Username", message: "This username may be taken. Usernames must be 3+ characters and only consist of letters and numbers.", close: "I'll do better this time.")
        return
      }

      self.dismissKeyboard()

      // ask for all of the relevant permissions and then createUser()
      self.pscope.show({ finished, results in
        // assume success
        for result in results {
          if result.status != .Authorized {
            return
          }
        }

        self.createUser()
      }, cancelled: { (results) -> Void in
          HUD.flash(.Error, delay: 0.5)
          self.chastiseUser()
      })
    }
  }

  func chastiseUser() {
    alert(title: "Whoops!", message: "How Many Rock Are There needs all of these permissions to function!", close: "I'll try again.")
  }

  func alert(title title: String, message: String, close: String) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .Alert
    )

    alert.addAction(UIAlertAction(title: close, style: .Default, handler: nil))

    self.presentViewController(alert, animated: true, completion: nil)
  }

  func dismissKeyboard() {
    usernameField.resignFirstResponder()
  }

  func createUser() {
    THE_DATABASE.sharedDatabase.createUser(usernameField.text ?? "") {
      HUD.flash(.Success, delay: 0.5)
      // assume the user is created, lol error handling
      self.delegate?.didFinish()
    }
  }
}
