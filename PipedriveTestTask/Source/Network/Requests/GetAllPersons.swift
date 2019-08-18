//
//  GetAllPersons.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import Alamofire

private let token = "2c7fa96579fb1cc0260e958158c9a131c56ec3be"

class GetAllPersonsRequest: SimpleRequest {

    let path = "persons"
    let parser = JSONParser<[Person]>()

    let parameters: Parameters?
    let encoding: ParameterEncoding = URLEncoding.default

    init(start: Int, limit: Int) {
        parameters = [
            "api_token": token,
            "start": start,
            "limit": limit,
            "sort": "id"
        ]
    }
    
}
