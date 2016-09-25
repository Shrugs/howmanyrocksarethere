//
//  THE_DATABASE.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import Alamofire

let PROB_THRESH = 0.4

class THE_DATABASE {

  static let sharedDatabase = THE_DATABASE()

  var token : String? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
    }
    set {
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setObject(newValue, forKey: "token")
      defaults.synchronize()
    }
  }

  var currentUser : [String: String]? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as? [String: String]
    }
    set {
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setObject(newValue, forKey: "currentUser")
      defaults.synchronize()
    }
  }

  var clarifaiAuthToken : String?

  let baseUrl = Constants.Urls.Base


  func refreshClarifaiAccessToken() {
    Alamofire.request(.POST, "https://api.clarifai.com/v1/token/", parameters: [
      "client_id": Clarifai.ClientId,
      "client_secret": Clarifai.ClientSecret,
      "grant_type": "client_credentials"
    ])
    .responseJSON { resp in
      switch resp.result {
      case .Success(let JSON):
        if let ret = JSON as? [String: String] {
          self.clarifaiAuthToken = ret["access_token"]
          print("Authenticated with Clarifai")
        }
      default:
        print("Clarifai Authentication Failed")
        print(resp)
      }
    }
  }

  func isValidUsername(username: String, cb: (Bool) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/valid-username", parameters: [
      "username": username
    ])
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          let rocks = JSON as! [String: Bool]
          cb(rocks["valid"]!)
        default:
          cb(false)
        }
    }
  }

  func createUser(username: String, cb: () -> Void) {
    // create the user
    // store the token in nsuserdefaults
    Alamofire.request(.POST, "\(baseUrl)/users", headers: [
      "Accept": "application/json"
    ], parameters: [
      "username": username
    ], encoding: .JSON)
    .responseJSON { resp in
      switch resp.result {
      case .Success(let JSON):
        let data = JSON as! [String: String]
        self.token = data["token"]!
        self.currentUser = data
        cb()
      default:
        debugPrint(resp)
      }
    }
  }

  func submitRock(params: [String: AnyObject], cb: () -> Void) {
    Alamofire.request(.POST, "\(baseUrl)/rocks", headers: [
      "Authorization": "Token token=\(self.token ?? "")",
      "Accept": "application/json"
    ], parameters: params, encoding: .JSON)
    .responseJSON { resp in
      switch resp.result {
      case .Success:
        cb()
      default:
        debugPrint(resp)
      }
    }
  }

  func submitNotRock(params: [String: AnyObject], cb: () -> Void) {
    Alamofire.request(.POST, "\(baseUrl)/notrocks", headers: [
      "Authorization": "Token token=\(self.token ?? "")",
      "Accept": "application/json"
    ], parameters: params, encoding: .JSON)
      .responseJSON { resp in
        switch resp.result {
        case .Success:
          cb()
        default:
          debugPrint(resp)
        }
    }
  }

  func getRocks(lastCreatedAt: String?, cb: ([Rock]) -> Void) {
    var params = [String: String]()
    if let lastCreatedAt = lastCreatedAt {
      params["lastCreatedAt"] = lastCreatedAt
    }
    Alamofire.request(.GET, "\(baseUrl)/rocks", parameters: params)
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          let rocks = JSON as! [Rock]
          cb(rocks)
        default:
           debugPrint(resp)
        }
      }
  }

  func getRock(rockId: String, cb: (Rock) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/rock/\(rockId)")
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          let rock = JSON as! Rock
          cb(rock)
        default:
          debugPrint(resp)
        }
    }
  }

  func getTotalRocks(cb: (Int) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/total-rocks")
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          let rocks = JSON as! [String: Int]
          cb(rocks["count"] ?? 0)
        default:
          cb(0)
        }
    }
  }

  func getNearbyRocks(lat lat: Double, lng: Double, radius: Int = 20, cb: ([Rock]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/nearbyrocks", parameters: [
      "lat": lat,
      "lng": lng,
      "radius": radius
    ])
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          let rocks = JSON as! [Rock]
          cb(rocks)
        default:
          debugPrint(resp)
        }
    }
  }

  func discoverRock(rockId: String, cb: (Rock) -> Void) {
    Alamofire.request(.POST, "\(baseUrl)/rock/\(rockId)/discover", headers: [
      "Authorization": "Token token=\(self.token ?? "")",
      "Accept": "application/json"
    ], encoding: .JSON)
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          cb(JSON as! Rock)
        default:
          debugPrint(resp)
        }
    }
  }

  func isRock(imageUrl: String, cb: (Bool) -> Void) {
    if let token = self.clarifaiAuthToken {
      Alamofire.request(.GET, "https://api.clarifai.com/v1/tag", parameters: [
        "access_token": token,
        "url": imageUrl,
        "select_classes": "rock"
        ])
        .responseJSON { resp in
          switch resp.result {
          case .Success(let JSON):
            let results = (JSON as! [String: AnyObject])["results"] as! [[String: AnyObject]]
            let result = results.first!["result"] as! [String: AnyObject]
            let probs = (result["tag"] as! [String: AnyObject])["probs"] as! [Double]
            // if any of the probs are > 0.4, call it a rock
            for prob in probs {
              if prob > PROB_THRESH {
                cb(true)
                return
              }
            }
            cb(false)
          default:
            cb(true)
          }
      }
    } else {
      cb(true)
    }
  }
}































