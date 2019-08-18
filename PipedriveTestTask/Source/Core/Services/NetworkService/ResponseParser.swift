//
//  ResponseParser.swift
//
//  Created by Rumata on 12/28/17.
//

import Foundation

public protocol ResponseParser {
  
  associatedtype Representation
  
  func parse(_ data: Data) throws -> Representation
  
}

