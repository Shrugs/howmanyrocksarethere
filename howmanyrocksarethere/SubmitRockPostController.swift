//
//  NewRockPostController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import TextFieldEffects

let TEXT_FIELD_OFFSET = 10
let TEXT_FIELD_HEIGHT = 60

protocol SubmitRockPostControllerDelegate {
  func didFinish()
}

class SubmitRockPostController : UIViewController {

  var image : UIImage!
  var nicknameField : UITextField!
  var notesField : UITextField!
  let container = UIScrollView()
  let content = UIView()

  var delegate : SubmitRockPostControllerDelegate?

  convenience init(image: UIImage) {
    self.init(nibName: nil, bundle: nil)

    self.image = image
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(container)
    container.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }

    container.addSubview(content)
    content.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }

    view.backgroundColor = Constants.Color.AltBackground

    let imageView = UIImageView(image: image)
    content.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.top.left.right.equalTo(view)
      make.height.equalTo(view.snp_width)
    }

    nicknameField = newTextField("Nick Name")

    content.addSubview(nicknameField)
    nicknameField.snp_makeConstraints { make in
      make.top.equalTo(imageView.snp_bottom).offset(TEXT_FIELD_OFFSET)
      make.left.right.equalTo(view)
      make.height.equalTo(TEXT_FIELD_HEIGHT)
    }

    notesField = newTextField("Comment")

    content.addSubview(notesField)
    notesField.snp_makeConstraints { make in
      make.top.equalTo(nicknameField.snp_bottom).offset(TEXT_FIELD_OFFSET)
      make.left.right.equalTo(view)
      make.height.equalTo(TEXT_FIELD_HEIGHT)
    }

    let v = UIView()
    v.backgroundColor = .redColor()
    content.addSubview(v)
    v.snp_makeConstraints { make in
      make.left.right.equalTo(view)
      make.top.equalTo(notesField.snp_bottom).offset(10)
      make.height.equalTo(300)
    }
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
  }

  override func viewWillAppear(animated: Bool) {
    listenToKeyboard()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    print(container.contentSize)
  }

  func newTextField(placeholder: String) -> KaedeTextField {
    let textField = KaedeTextField()
    textField.placeholderColor = Constants.Color.White
    textField.foregroundColor = Constants.Color.TintColor
    textField.placeholder = placeholder

    return textField
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
