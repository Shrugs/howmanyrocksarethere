//
//  RockMapViewController.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Async

let DEFAULT_RADIUS = 3000 // meters

class RockMapViewController: UIViewController {

  var hasCentered = false
  var isFetchingRocks = true

  let locationManager = CLLocationManager()

  lazy var mapView : MKMapView = { [unowned self] in
    let mapView = MKMapView()
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .Follow
    mapView.delegate = self
    return mapView
  }()

  lazy var centerButton : UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.backgroundColor = Constants.Color.OffWhite
    button.layer.cornerRadius = 20
    button.tintColor = Constants.Color.TintColor
    button.setImage(UIImage(named: "ic_my_location")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    button.addTarget(self, action: #selector(centerOnUser), forControlEvents: .TouchUpInside)
    return button
  }()

  var rocks = [Rock]()

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

    self.edgesForExtendedLayout = UIRectEdge.None

    view.addSubview(mapView)
    mapView.snp_makeConstraints { make in
      make.edges.equalTo(view)
    }

    view.addSubview(centerButton)
    centerButton.snp_makeConstraints { make in
      make.bottom.right.equalTo(view).offset(-30)
      make.height.width.equalTo(40)
    }
  }

  func reloadData() {
    for rock in rocks {
      if let loc = rock["location"] as? [String: AnyObject],
        _ = loc["coordinates"] as? [Double] {

        let ann = RockAnnotation(rock: rock)
        mapView.addAnnotation(ann)
      }
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if let loc = mapView.userLocation.location {
      fetchRocks(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)
    }
  }

  let regionRadius: CLLocationDistance = 1000
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
    isFetchingRocks = false
    fetchRocks(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
  }

  func fetchRocks(lat lat: Double, lng: Double, radius: Int = DEFAULT_RADIUS) {
    isFetchingRocks = true
    Async.userInitiated {
      THE_DATABASE.sharedDatabase.getNearbyRocks(
        lat: lat,
        lng: lng,
        radius: radius
      ) { [weak self] rocks in
        Async.main {
          self?.isFetchingRocks = false
          self?.rocks = rocks
          self?.reloadData()
        }
      }
    }
  }

  func centerOnUser() {
    if let loc = mapView.userLocation.location {
      centerMapOnLocation(loc)
    }
  }
}

extension RockMapViewController : MKMapViewDelegate {

  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if !isFetchingRocks {
      let center = mapView.region.center
      let span = mapView.region.span

      let topRadius = CLLocation(
        latitude: center.latitude,
        longitude: center.longitude + (span.longitudeDelta / 2.0)
      ).distanceFromLocation(CLLocation(latitude: center.latitude, longitude: center.longitude))

      fetchRocks(
        lat: mapView.region.center.latitude,
        lng: mapView.region.center.longitude,
        radius: Int(topRadius)
      )
    }
  }

  func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
    if let loc = userLocation.location where !hasCentered {
      hasCentered = true
      centerMapOnLocation(loc)
    }
  }

  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("demo")

    if annotation.isEqual(mapView.userLocation) {
      return nil
    }

    if annotationView == nil {
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "demo")
      annotationView!.canShowCallout = true
      annotationView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    } else {
      annotationView!.annotation = annotation
    }

    annotationView!.image = UIImage(named: "maprock")

    return annotationView

  }

  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let ann = view.annotation as! RockAnnotation
    let vc = RockProfileController(rock: ann.rock)
    vc.delegate = self
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension RockMapViewController : RockProfileControllerDelegate {
  func shouldCloseProfileController(profileController: RockProfileController) {
    self.navigationController?.popViewControllerAnimated(true)
  }
}



























