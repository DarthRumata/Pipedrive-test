//
//  ErrorProcessor.swift
//  External
//
//  Created by Stas Kirichok on 22-10-2018.
//  Copyright © 2018 Stas Kirichok. All rights reserved.
//

import Foundation
import Alamofire

public protocol ErrorProcessor: class {
  
  func process(error: Error, with response: HTTPURLResponse, data: Data?) -> Error
  
}

public class DefaultErrorProcessor: ErrorProcessor {
  
  public init() {}
  
  public func process(error: Error, with response: HTTPURLResponse, data: Data?) -> Error {
    return error
  }
  
}
