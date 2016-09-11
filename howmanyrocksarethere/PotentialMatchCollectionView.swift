//
//  PotentialMatchCollectionView.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import WebImage

let muhCellIdentifier = "potential_cell"

protocol PotentialMatchCollectionDelegate {
  func didSelectPotentialMatch(rock: [String: AnyObject])
  func didChooseUniqueRock()
}

class PotentialMatchCollectionView : UIViewController {

  var delegate : PotentialMatchCollectionDelegate?

  var rocks = [[String: AnyObject]]()

  lazy var collectionView : UICollectionView = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0

    let collectionView = UICollectionView(frame: CGRectNull, collectionViewLayout: layout)
    collectionView.delaysContentTouches = true
    collectionView.backgroundColor = Constants.Color.BackgroundColor
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(PotentialMatch.self, forCellWithReuseIdentifier: muhCellIdentifier)
    collectionView.registerClass(UniqueRockButton.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
    collectionView.registerClass(PotentialMatchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "pheader")

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
    THE_DATABASE.sharedDatabase.getPotentialRocks { [weak self] rocks in
      self?.rocks = rocks
      self?.collectionView.reloadData()
    }
  }

  override func viewDidAppear(animated: Bool) {
    loadRocks()
  }

}

extension PotentialMatchCollectionView : UICollectionViewDelegate {
}

extension PotentialMatchCollectionView : UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width = self.view.frame.size.width
    return CGSize(width: width, height: width * 1.55 + 150)
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSize(width: self.view.frame.size.width, height: 50)
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: self.view.frame.size.width, height: 70)
  }
}

extension PotentialMatchCollectionView : UniqueRockButtonDelegate {
  func didSelectUniqueRock() {
    delegate?.didChooseUniqueRock()
  }
}

extension PotentialMatchCollectionView : UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

    if kind == UICollectionElementKindSectionFooter {
      let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "footer", forIndexPath: indexPath)
      let nCell = cell as! UniqueRockButton
      nCell.delegate = self
      return nCell
    } else {
      let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "pheader", forIndexPath: indexPath)
      return cell as! PotentialMatchHeader
    }
  }


  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return rocks.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(muhCellIdentifier, forIndexPath: indexPath) as! PotentialMatch

    let rock = rocks[indexPath.row]

    cell.setRock(rock)
    cell.delegate = self

    return cell
  }

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

extension PotentialMatchCollectionView : PotentialMatchDelegate {
  func didSelectPotentialMatch(rock: [String : AnyObject]) {
    delegate?.didSelectPotentialMatch(rock)
  }
}





























