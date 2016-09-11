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

  init(title: String, description: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.subtitle = description
    self.coordinate = coordinate

    super.init()
  }
}
