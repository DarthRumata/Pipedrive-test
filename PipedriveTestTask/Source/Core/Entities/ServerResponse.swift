//
//  ServerResponse.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation

struct ServerResponse<T: Decodable>: Decodable {
    let data: T
    let pagination: Pagination

    private enum CodingKeys: String, CodingKey {
        case data
        case additionalData = "additional_data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(T.self, forKey: .data)
        let additionalData = try container.decode(AdditionalData.self, forKey: .additionalData)
        pagination = additionalData.pagination
    }

    init(data: T) {
        self.data = data
        self.pagination = Pagination.empty()
    }
    
}

struct AdditionalData: Decodable {
    let pagination: Pagination
}
