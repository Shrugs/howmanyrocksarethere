//
//  FeedViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import WebImage

let cellIdentifier = "cell"

class FeedViewController : UIViewController {

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

    view.backgroundColor = Constants.Color.BackgroundColor

    view.addSubview(collectionView)
    collectionView.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }
  }

  func loadRocks() {
    THE_DATABASE.sharedDatabase.getRocks { [weak self] rocks in
      self?.rocks = rocks
      self?.collectionView.reloadData()
      self?.refreshControl.endRefreshing()
    }
  }

  override func viewDidAppear(animated: Bool) {
    loadRocks()
  }

}

extension FeedViewController : UICollectionViewDelegate {
}

extension FeedViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width = self.view.frame.size.width
    return CGSize(width: width, height: width * 1.55)
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: self.view.frame.size.width, height: 50)
  }
}

extension FeedViewController : UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! FeedHeader
    cell.titleLabel.text = "00000000001 rocks"
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






























