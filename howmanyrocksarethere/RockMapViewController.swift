//
//  RockMapViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import MapKit

class RockMapViewController: UIViewController {

  let mapView : MKMapView = {
    let mapView = MKMapView()
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .Follow
    return mapView
  }()

  var rocks = [[String: AnyObject]]()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)
    self.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "ic_near_me"), selectedImage: UIImage(named: "ic_near_me"))
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(mapView)
    mapView.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }

    fetchRocks()
  }

  func reloadData() {
    for rock in rocks {
      if let lat = rock["lat"] as? Double, lng = rock["lng"] as? Double {
        let ann = RockAnnotation(
          title: (rock["nickname"] ?? "Some Rock") as! String,
          description: "",
          coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
        )

        mapView.addAnnotation(ann)
      }
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    centerMapOnLocation(CLLocation(latitude: 40.742268, longitude: -73.987988))
  }

  let regionRadius: CLLocationDistance = 1000
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }

  func fetchRocks() {
    THE_DATABASE.sharedDatabase.getRocks { [weak self] rocks in
      self?.rocks = rocks
      self?.reloadData()
    }
  }
}





























