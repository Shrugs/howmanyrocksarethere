//
//  NewRockPostController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import TextFieldEffects
import AWSS3

let TEXT_FIELD_OFFSET = 10
let TEXT_FIELD_HEIGHT = 60

protocol SubmitRockPostControllerDelegate {
  func didFinish()
}

class SubmitRockPostController : UIViewController {

  var image : UIImage!
  lazy var nicknameField : UITextField = { [unowned self] in
    return self.newTextField("Nick Name *")
  }()
  lazy var notesField : UITextField = { [unowned self] in
    return self.newTextField("Notes *")
  }()
  let container = UIScrollView()
  let content = UIView()

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

  convenience init(image: UIImage) {
    self.init(nibName: nil, bundle: nil)

    self.image = image
  }

  override func viewDidLoad() {
    super.viewDidLoad()

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
      make.top.equalTo(notesField.snp_bottom).offset(25)
      make.left.right.equalTo(content)
      make.bottom.equalTo(continueButton.snp_top)
    }
  }

  func submitRock() {
    // @TODO(shrugs) start a loading indicator
    // start request to submit the rock
    // exit loading indicator
    // trigger delegate close method

    let loading = LoadingController()
    presentViewController(loading, animated: false, completion: nil)

    let path : String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("image.png")
    let resizedImage = resizeImage(image, newSize: CGSize(width: 256, height: 256))
    UIImagePNGRepresentation(resizedImage)!.writeToFile(path as String, atomically: true)

    let key = "\(randomAlphaNumericString(10)).png"

    let url : NSURL = NSURL(fileURLWithPath: path)
    let uploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.bucket = AWS.S3.BucketName
    uploadRequest.ACL = .PublicRead
    uploadRequest.key = key
    uploadRequest.contentType = "image/png"
    uploadRequest.body = url

//    uploadRequest.uploadProgress = {[unowned self] (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
//      dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//        // @TODO(shrugs) update UI with progress
////        self.amountUploaded = totalBytesSent
////        self.filesize = totalBytesExpectedToSend;
////        self.update()
//      })
//    }

    let transferManager : AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    // start the upload
    transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
      // once the uploadmanager finishes check if there were any errors
      if (task.error != nil) {
        print(task.error)
        return nil
      }

      let imageUrl = s3Url(key)

      THE_DATABASE.sharedDatabase.submitRock([
        "lat": 72.00,
        "lng": 93.0,
        "image": imageUrl,
        "nickname": self.nicknameField.text ?? "",
        "comment": self.notesField.text ?? ""
      ]) {
        // assume success
        // @TODO(shrugs) remove loading view here
        self.dismissViewControllerAnimated(false) { [unowned self] in
          self.delegate?.didFinish()
        }
      }
      return nil
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
  }

  override func viewWillAppear(animated: Bool) {
    listenToKeyboard()
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
