//
//  PersonsNetworkRepository.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxSwift

class PersonsNetworkRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getPersons(start: Int = 0, limit: Int = 15) -> Observable<ServerResponse<[Person]>> {
        let request = GetAllPersonsRequest(start: start, limit: limit)
        return networkService.executeRequest(request)
            .asObservable()
    }

}
