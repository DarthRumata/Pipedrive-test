//
//  FailableDecodable.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 13-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation

struct FailableDecodable<Base: Decodable>: Decodable {

    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            base = try container.decode(Base.self)
        } catch let error {
            print(error)
            base = nil
        }
    }
}
