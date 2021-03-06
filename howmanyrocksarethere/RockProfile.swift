//
//  RockProfile.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/11/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import UIKit

class RockProfile: UIView {

  var discoveredBy = UILabel()
  var imageView = UIImageView()
  var style : String = ""

  lazy var ownerInitial : UILabel = {
    let label = UILabel()
    label.font = UIFont(name: Constants.Text.BoldFont.Name, size: Constants.Text.BoldFont.Size)
    label.text = "?"
    label.textAlignment = .Center
    label.textColor = Constants.Color.White
    return label
  }()

  lazy var ownerImage : UIView = {
    let view = UIView()
    view.backgroundColor = Constants.Color.TintColor
    return view
  }()

  let ownerName = UILabel()

  var answerLabels = [UILabel]()

  convenience init() {
    self.init(frame: CGRect.zero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = Constants.Color.AltBackground

    self.addSubview(imageView)
    imageView.snp_makeConstraints { make in
      make.top.left.right.equalTo(self)
      make.height.equalTo(imageView.snp_width)
    }

    let imageRatio = 0.8
    let imageRadius = (ownerHeight * imageRatio) / 2.0
    let ownerView = UIView()
    ownerImage.layer.cornerRadius = CGFloat(imageRadius)
    ownerImage.layer.masksToBounds = true

    ownerView.addSubview(ownerImage)
    ownerImage.snp_makeConstraints { make in
      make.left.equalTo(ownerView).offset(8)
      make.centerY.equalTo(ownerView)
      make.height.equalTo(ownerView.snp_height).multipliedBy(imageRatio)
      make.width.equalTo(ownerImage.snp_height)
    }

    ownerImage.addSubview(ownerInitial)
    ownerInitial.snp_makeConstraints { make in
      make.right.bottom.equalTo(ownerImage)
      make.top.equalTo(ownerImage).offset(2)
      make.left.equalTo(ownerImage).offset(1)
    }

    let discoveredBy = UILabel()

    discoveredBy.font = UIFont(name: Constants.Text.TitleFont.Name, size: 14)
    discoveredBy.textColor = .grayColor()
    discoveredBy.textAlignment = .Left
    discoveredBy.text = "DISCOVERED BY"

    ownerView.addSubview(discoveredBy)
    discoveredBy.snp_makeConstraints { make in
      make.left.equalTo(ownerImage.snp_right).offset(10)
      make.right.equalTo(ownerView)
      make.top.equalTo(ownerView).offset(8)
      make.bottom.equalTo(ownerView.snp_centerY)
    }

    ownerName.font = UIFont(name: Constants.Text.TitleFont.Name, size: 22)
    ownerName.textColor = Constants.Color.BackgroundColor
    ownerName.textAlignment = .Left

    ownerView.addSubview(ownerName)
    ownerName.snp_makeConstraints { make in
      make.left.equalTo(ownerImage.snp_right).offset(10)
      make.right.equalTo(discoveredBy)
      make.top.equalTo(discoveredBy.snp_bottom).offset(-10)
      make.bottom.equalTo(ownerView)
    }

    self.addSubview(ownerView)
    ownerView.snp_makeConstraints { make in
      make.top.equalTo(imageView.snp_bottom)
      make.left.right.equalTo(self)
      make.height.equalTo(60)
    }

    let border = UIView()
    border.backgroundColor = UIColor.blackColor()
    ownerView.addSubview(border)
    border.snp_makeConstraints { make in
      make.bottom.left.right.equalTo(ownerView)
      make.height.equalTo(1)
    }

    // properties

    let columns = [
      "ROCK NO.",
      "COORDINATES",
      "DISCOVERED",
      "NICKNAME",
      "NOTES"
    ]

    // for each column, lay out a label
    let columnLabels = columns.enumerate().map { (i, col) -> UILabel in
      let label = newColumnLabel()
      label.text = col
      self.addSubview(label)
      return label
    }

    columnLabels.enumerate().forEach { (i, label) in
      label.snp_makeConstraints { make in
        make.left.equalTo(self)
        make.width.equalTo(self.snp_width).multipliedBy(0.3)

        if (i == columnLabels.count - 1) {
          make.height.equalTo(40)
        } else {
          make.height.equalTo(16)
        }

        if (i == 0) {
          make.top.equalTo(ownerView.snp_bottom).offset(10)
        } else {
          make.top.equalTo(columnLabels[i - 1].snp_bottom).offset(5)
        }
      }
    }

    answerLabels = columnLabels.enumerate().map({ (i, colLabel) -> UILabel in
      let label = newAnswerLabel(i == 1 ? 12 : i == 2 ? 14 : 16)
      self.addSubview(label)
      label.snp_makeConstraints { make in
        make.top.bottom.equalTo(colLabel)
        make.left.equalTo(colLabel.snp_right).offset(10)
        make.right.equalTo(self).offset(-10)
      }
      return label
    })
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func newColumnLabel() -> UILabel {
    let label = UILabel()

    label.font = UIFont(name: Constants.Text.TitleFont.Name, size: 16)
    label.textColor = .grayColor()
    label.textAlignment = .Right

    return label
  }

  func newAnswerLabel(size: Int = 16) -> UILabel {
    let label = UILabel()

    label.font = UIFont(name: Constants.Text.TitleFont.Name, size: CGFloat(size))
    label.textColor = .blackColor()
    label.textAlignment = .Left
    label.numberOfLines = 3
    
    return label
  }

  func setRock(rock: Rock) {
    let owner = rock["owner"] as! [String: String]

    ownerName.text = owner["username"]
    ownerInitial.text = String((owner["username"] ?? "?").characters.first!).uppercaseString
    imageView.sd_setImageWithURL(NSURL(string: rock["image"] as! String))

    // properties

    let location = rock["location"] as! [String: AnyObject]
    let coord = location["coordinates"] as! [Double]
    let lng = coord[0]
    let lat = coord[1]

    answerLabels[0].text = "#0000\(rock["id"] as! Int)"
    answerLabels[1].text = "\(lat), \(lng)"
    answerLabels[2].text = rock["created_at"] as? String
    answerLabels[3].text = rock["nickname"] as? String
    answerLabels[4].text = rock["comment"] as? String
  }
}































