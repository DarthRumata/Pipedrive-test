//
//  JSONParser.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation

struct JSONParser<T: Decodable>: ResponseParser {

    func parse(_ data: Data) throws -> ServerResponse<T> {
        let decoder = JSONDecoder()
        return try decoder.decode(ServerResponse<T>.self, from: data)
    }

}
