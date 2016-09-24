//
//  PotentialMatchCollectionView.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import WebImage
import CoreLocation
import PKHUD
import SnapKit

let muhCellIdentifier = "potential_cell"

protocol PotentialMatchCollectionDelegate {
  func didSelectPotentialMatch(rock: Rock)
  func didChooseUniqueRock()
}

class PotentialMatchCollectionView : UIViewController {

  var didGetLocation = false
  let locationManager = CLLocationManager()

  var delegate : PotentialMatchCollectionDelegate?

  var rocks = [Rock]()

  lazy var uniqueButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.TintColor
    button.setTitle("MY ROCK IS UNIQUE", forState: .Normal)
    button.setTitleColor(Constants.Color.White, forState: .Normal)
    button.addTarget(self, action: #selector(uniqueButtonTapped), forControlEvents: .TouchUpInside)
    return button
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
    collectionView.registerClass(PotentialMatch.self, forCellWithReuseIdentifier: muhCellIdentifier)
    collectionView.registerClass(UniqueRockButton.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
    collectionView.registerClass(PotentialMatchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "pheader")

    return collectionView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self

    view.backgroundColor = Constants.Color.BackgroundColor

    view.addSubview(collectionView)
    collectionView.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }
  }

  func loadRocks(location: CLLocation, showHUD: Bool = false) {
    THE_DATABASE.sharedDatabase.getNearbyRocks(
      lat: location.coordinate.latitude,
      lng: location.coordinate.longitude,
      radius: 50
    ) { rocks in
      self.rocks = rocks
      self.collectionView.reloadData()

      if showHUD {
        HUD.flash(.Success, delay: 0.3)
      }

      // if there are no nearby rocks
      // put a big "my rock is unique"

      if rocks.count == 0 {
          self.view.addSubview(self.uniqueButton)
          self.uniqueButton.snp_makeConstraints { make in
              make.center.equalTo(self.view)
              make.width.equalTo(self.view).multipliedBy(0.8)
              make.height.equalTo(50)
          }
      }
    }
  }

  override func viewDidAppear(animated: Bool) {
    HUD.show(.Progress)

    locationManager.requestWhenInUseAuthorization()
  }

  func uniqueButtonTapped() {
    self.delegate?.didChooseUniqueRock()
  }

}

extension PotentialMatchCollectionView : UICollectionViewDelegate {
}

extension PotentialMatchCollectionView : UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width = self.view.frame.size.width
    return CGSize(width: width, height: width * 1.60 + 150)
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if self.rocks.count == 0 {
      return CGSize(width: self.view.frame.size.width, height: 0)
    }
    
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
      let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "pheader", forIndexPath: indexPath) as! PotentialMatchHeader
      cell.label.text = self.rocks.count == 0 ?
        "NO ROCKS NEAR YOU. YOUR ROCK IS UNIQUE." :
      "THESE ROCKS HAVE ALREADY BEEN DISCOVERED NEAR YOU."

      return cell
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

extension PotentialMatchCollectionView : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if (status == .AuthorizedWhenInUse) {
      locationManager.startUpdatingLocation()
    }
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let loc = locations.first where !didGetLocation {
      didGetLocation = true
      self.loadRocks(loc, showHUD: true)
    }
  }
}

extension PotentialMatchCollectionView : PotentialMatchDelegate {
  func didSelectPotentialMatch(rock: [String : AnyObject]) {
    delegate?.didSelectPotentialMatch(rock)
  }
}





























