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

protocol LoginViewControllerDelegate {
  func didFinish()
}

class LoginViewController: UIViewController {

  let pscope = PermissionScope()

  lazy var usernameField : UITextField = {
    let textField = YokoTextField()
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

    let imageView = UIImageView(image: UIImage(named: "Logo"))
    view.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.top.equalTo(view).offset(40)
      make.centerX.equalTo(view)
      make.width.equalTo(view).multipliedBy(0.4)
      make.height.equalTo(imageView.snp_width)
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

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.AltBackground

    view.addSubview(banner)
    banner.snp_makeConstraints { make in
      make.top.left.right.equalTo(view)
      make.height.equalTo(290)
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
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    usernameField.becomeFirstResponder()
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  func login() {
    // on login, ask for all of the relevant permissions and then createUser()
    pscope.show({ finished, results in
      // assume success
      for result in results {
        if result.status != .Authorized {
          return
        }
      }

      self.createUser()
    }, cancelled: { (results) -> Void in
      self.chastiseUser()
    })
  }

  func chastiseUser() {
    let alert = UIAlertController(
      title: "Whoops!",
      message: "How Many Rock Are There needs all of these permissions to function!",
      preferredStyle: .Alert
    )

    self.presentViewController(alert, animated: true, completion: nil)
  }

  func dismissKeyboard() {
    usernameField.resignFirstResponder()
  }

  func createUser() {
    THE_DATABASE.sharedDatabase.createUser(usernameField.text ?? "") {
      // assume the user is created, lol error handling
      self.delegate?.didFinish()
    }
  }
}
