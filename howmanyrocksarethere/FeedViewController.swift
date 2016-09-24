//
//  FeedViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import WebImage
import PKHUD
import Async

let cellIdentifier = "cell"

class FeedViewController : UIViewController {

  var isLoadingRocks = false
  var totalRockCount = 0

  var rocks = [[String: AnyObject]]()

  lazy var refreshControl : UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = Constants.Color.BackgroundColor
    refreshControl.tintColor = Constants.Color.White
    return refreshControl
  }()

  lazy var collectionView : UICollectionView = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionHeadersPinToVisibleBounds = true

    let collectionView = UICollectionView(frame: CGRectNull, collectionViewLayout: layout)
    collectionView.delaysContentTouches = true
    collectionView.backgroundColor = Constants.Color.BackgroundColor
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(FeedItem.self, forCellWithReuseIdentifier: cellIdentifier)

    collectionView.registerClass(FeedHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")

    self.refreshControl.addTarget(self, action: #selector(loadRocks), forControlEvents: .ValueChanged)
    collectionView.addSubview(self.refreshControl)
    return collectionView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "ic_list"), selectedImage: UIImage(named: "ic_list"))
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    view.backgroundColor = Constants.Color.BackgroundColor

    view.addSubview(collectionView)
    collectionView.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }

    loadRocks(true)
  }

  func loadRocks(showHUD: Bool = false) {
    if showHUD {
      HUD.show(.Progress)
    }
    Async.userInitiated {
      THE_DATABASE.sharedDatabase.getRocks(nil) { [weak self] rocks in
        Async.main {
          if showHUD {
            HUD.flash(.Success, delay: 0.1)
          }
          self?.rocks = rocks
          self?.collectionView.reloadData()
          self?.refreshControl.endRefreshing()
        }
      }
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadRocks()
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

extension FeedViewController : UICollectionViewDelegate {

  func possiblyLoadRocks(scrollView: UIScrollView) {
    let actualPosition = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height - 700
    if actualPosition >= contentHeight && !isLoadingRocks {
      HUD.show(.Progress)
      PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true

      isLoadingRocks = true
      // reload the data, append to the bottom of self.rocks
      if let lastRock = self.rocks.last {
        Async.userInitiated {
          THE_DATABASE.sharedDatabase.getRocks(lastRock["created_at"] as? String) { (rocks) in
            Async.main {
              HUD.hide()
              self.isLoadingRocks = false
              self.rocks.appendContentsOf(rocks)
              self.collectionView.reloadData()
            }
          }
        }
      }
    }
  }

  func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
    possiblyLoadRocks(scrollView)
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    possiblyLoadRocks(scrollView)
  }
}

extension FeedViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width = self.view.frame.size.width
    return CGSize(width: width, height: width * 1.60)
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: self.view.frame.size.width, height: 120)
  }
}

extension FeedViewController : UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! FeedHeader
    cell.titleLabel.text = "000000000000 rocks"

    cell.titleLabel.text = "\(String(format: "%012d", totalRockCount)) rocks"

    THE_DATABASE.sharedDatabase.getTotalRocks { numRocks in
      self.totalRockCount = numRocks
      cell.titleLabel.text = "\(String(format: "%012d", numRocks)) rocks"
    }

    cell.delegate = self
    return cell
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return rocks.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedItem

    let rock = rocks[indexPath.row]

    cell.setRock(rock)

    return cell
  }

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
}

extension FeedViewController : SubmitRockFlowControllerDelegate {
  func shouldClose() {
    loadRocks()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension FeedViewController : FeedHeaderDelegate {
  func didTapNewRock() {
    let submitController = SubmitRockFlowController()
    submitController.cDelegate = self
    submitController.view.frame = self.view.bounds
    self.presentViewController(submitController, animated: true, completion: nil)
  }
}





























