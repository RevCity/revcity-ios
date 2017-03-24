//
//  NetworkRequest.swift
//  RevCity
//
//  Created by Daniel Li on 3/24/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import Alamofire
import SwiftyJSON

let revBaseURL: String = "http://localhost:8080"

protocol NetworkRequestable {
    associatedtype T
    var baseURL: String { get }
    var route: String { get }
    var method: HTTPMethod { get }
    var parameters: [String : Any] { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders? { get }
    
    func process(json: JSON) -> T
}

extension NetworkRequestable {
    var baseURL: String { return revBaseURL }
    var route: String { return "/" }
    var method: HTTPMethod { return .get }
    var parameters: [String : Any] { return [:] }
    var encoding: ParameterEncoding { return method == .get ? URLEncoding.default : JSONEncoding.default }
    var headers: HTTPHeaders? { return nil }
    
    func make(onSuccess: ((T) -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Alamofire.request(URL(string: baseURL + route)!, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    onSuccess?(self.process(json: JSON(data)))
                case .failure(let error):
                    onFailure?(error)
                }
        }
    }
}


