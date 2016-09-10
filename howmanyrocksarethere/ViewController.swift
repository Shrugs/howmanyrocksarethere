//
//  ViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

  let tabBar = UITabBar()

  override func viewDidLoad() {
    super.viewDidLoad()

    let list = UITabBarItem(title: nil, image: UIImage(named: "ic_list"), selectedImage: UIImage(named: "ic_list"))
    let camera = UITabBarItem(title: nil, image: UIImage(named: "ic_photo_camera"), selectedImage: UIImage(named: "ic_photo_camera"))

    tabBar.items = [
      list,
      camera
    ]
    tabBar.items?.enumerate().forEach({ (i, item) in
      item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
      item.tag = i
    })
    tabBar.selectedItem = tabBar.items!.first!
    tabBar.delegate = self

    view.addSubview(tabBar)
    tabBar.snp_makeConstraints { make in
      make.bottom.left.right.equalTo(view)
      make.height.equalTo(49)
    }

    let feed = FeedViewController()

    self.addChildViewController(feed)
    self.view.addSubview(feed.view)
    feed.view.snp_makeConstraints { make in
      make.top.left.right.equalTo(self.view)
      make.bottom.equalTo(tabBar.snp_top)
    }
    feed.didMoveToParentViewController(self)

  }

}

extension ViewController : UITabBarDelegate {
  func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    // if item is the second one
    if (item.tag == 1) {
      // present fusuma UI
      let submitController = SubmitRockFlowController()
      submitController.cDelegate = self
      submitController.view.frame = self.view.bounds
      self.presentViewController(submitController, animated: true, completion: nil)
    }

    // @TODO(shrugs) - present any other view controllers if necessary
  }
}

extension ViewController : SubmitRockFlowControllerDelegate {
  func shouldClose() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}