//
//  RockAnnotation.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import MapKit

class RockAnnotation: NSObject, MKAnnotation {
  let title: String?
  let subtitle: String?
  let coordinate: CLLocationCoordinate2D
  let rock: Rock

  init(rock: Rock) {
    self.rock = rock

    self.title = (rock["nickname"] as? String) ?? "Some Rock"
    self.subtitle = (rock["comment"] as? String) ?? ""

    let loc = rock["location"] as! [String: AnyObject]
    let coords = loc["coordinates"] as! [Double]
    let lng = coords.first!
    let lat = coords.last!

    self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

    super.init()
  }
}
