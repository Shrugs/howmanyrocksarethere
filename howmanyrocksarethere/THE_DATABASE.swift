//
//  THE_DATABASE.swift
//  howmanyrocksarethere
//
//  Created by Matt Condon on 9/10/16.
//  Copyright © 2016 howmanyrocksarethere. All rights reserved.
//

import Alamofire

class THE_DATABASE {

  static let sharedDatabase = THE_DATABASE()

  var token : String? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey("token")?.stringValue
    }
    set {
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setObject(newValue, forKey: "token")
      defaults.synchronize()
    }
  }

  var clarifaiAuthToken : String?

  init() {
    // for now lol
    self.token = "e2727b5a558cee0ca00235055a25450ec1e076f47f377889c19af9d80750920258405554085f3dd78b63040885eee4d6941767b78e44a728b767e5705ab88a36"
  }

  let baseUrl = "http://howmanyrocks.ngrok.io"




  func refreshClarifaiAccessToken() {
    Alamofire.request(.POST, "https://api.clarifai.com/v1/token/", parameters: [
      "client_id": Clarifai.ClientId,
      "client_secret": Clarifai.ClientSecret,
      "grant_type": "client_credentials"
    ])
    .responseJSON { resp in
      switch resp.result {
      case .Success(let JSON):
        let ret = JSON as! [String: AnyObject]
        self.clarifaiAuthToken = ret["access_token"] as? String
        print("Authenticated with Clarifai")
      default:
        print("Clarifai Authentication Failed")
        print(resp)
      }
    }
  }

  func createUser(username: String) {
    // create the user
    // store the token in nsuserdefaults
  }

  func getRocks(cb: ([[String: AnyObject]]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/rocks")
      .responseJSON { resp in
        switch resp.result {
        case .Success(let JSON):
          let rocks = JSON as! [[String: AnyObject]]
          cb(rocks)
        default:
           print(resp)
        }
      }
  }
}
