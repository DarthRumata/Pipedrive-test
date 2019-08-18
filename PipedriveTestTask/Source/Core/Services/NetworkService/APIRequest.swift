//
//  APIRequest.swift
//
//  Created by Rumata on 12/28/17.
//

import Foundation
import Alamofire

public protocol APIRequest {
  associatedtype Parser: ResponseParser
  
  var path: String { get }
  var method: HTTPMethod { get }
  var parser: Parser { get }
  var headers: HTTPHeaders { get }
}

public extension APIRequest {
  
  var method: HTTPMethod {
    return .get
  }
  var headers: HTTPHeaders {
    return [:]
  }
  
}

public protocol SimpleRequest: APIRequest {
  
  var parameters: Parameters? { get }
  var encoding: ParameterEncoding { get }
  
}

public extension SimpleRequest {
  
  var parameters: Parameters? {
    return nil
  }
  
  var encoding: ParameterEncoding {
    return JSONEncoding.default
  }
  
}

public protocol UploadRequest: APIRequest {
  
  var data: Data { get }
  
}

public protocol MultipartRequest: APIRequest {
  
  var multiPartFormBuilder: (MultipartFormData) -> Void { get }
  
}

public extension UploadRequest {
  
  var method: HTTPMethod {
    return .post
  }
  
}

