//
//  Pagination.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation

struct Pagination: Decodable {
    let start: Int
    let limit: Int
    let hasMore: Bool

    private enum CodingKeys: String, CodingKey {
        case start
        case limit
        case hasMore = "more_items_in_collection"
    }

    static func empty() -> Pagination {
        return Pagination(start: 0, limit: 0, hasMore: false)
    }
}
