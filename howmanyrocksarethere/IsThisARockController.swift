//
//  IsThisARockController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import AWSS3

protocol IsThisARockControllerDelegate {
  func isRock(image: UIImage, url: String)
  func isNotRock(image: UIImage, url: String)
}

/**
 
 Given an image, send a request to clarifai to determine whether or not the image is of a rock.
 
 Show a loading indicator while the request is in progress.

*/
class IsThisARockController : UIViewController {

  var delegate : IsThisARockControllerDelegate?

  var image : UIImage!

  let loading = LoadingController()

  convenience init(image: UIImage) {
    self.init(nibName: nil, bundle: nil)

    self.image = image
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.Color.BackgroundColor

    addChildViewController(loading)
    view.addSubview(loading.view)
    loading.view.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }
    loading.didMoveToParentViewController(self)

    let path : String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("image.png")
    let resizedImage = resizeImage(image, newSize: CGSize(width: 128, height: 128))
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
    transferManager.upload(uploadRequest).continueWithBlock { [weak self] (task) -> AnyObject? in
      // once the uploadmanager finishes check if there were any errors
      if (task.error != nil) {
        print(task.error)
        return nil
      }
      
      let imageUrl = s3Url(key)

      THE_DATABASE.sharedDatabase.isRock(imageUrl) { isRock in
        if isRock {
          self?.delegate?.isRock((self?.image)!, url: imageUrl)
        } else {
          self?.delegate?.isNotRock((self?.image)!, url: imageUrl)
        }
      }

      return nil
    }
  }
}
