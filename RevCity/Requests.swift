//
//  Requests.swift
//  RevCity
//
//  Created by Daniel Li on 3/24/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LoginRequest: NetworkRequestable {
    typealias T = Int
    
    let idToken: String
    let timestamp: Date
    
    let baseURL: String = "http://google.com"
    let route: String = "/login"
    
    var parameters: [String : Any] {
        return [
            "idToken": idToken,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }
    
    func process(json: JSON) -> T {
        return json["session_code"].intValue
    }
}
