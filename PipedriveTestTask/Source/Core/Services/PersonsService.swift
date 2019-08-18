//
//  PersonsService.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxSwift

class PersonsService {

    private let storeRepository: PersonsStoreRepository
    private let networkRepository: PersonsNetworkRepository

    private let disposeBag = DisposeBag()

    init(storeRepository: PersonsStoreRepository, networkRepository: PersonsNetworkRepository) {
        self.storeRepository = storeRepository
        self.networkRepository = networkRepository
    }

    func getFirstPagePersons(useCache: Bool) -> Observable<ServerResponse<[Person]>> {
        let relay = PublishSubject<ServerResponse<[Person]>>()
        var hasFinalResults = false
        networkRepository.getPersons()
            .do(onNext: { [weak self] response in
                guard let self = self else { return }
                self.storeRepository.savePersons(response.data)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .subscribe(onNext: { response in
                relay.onNext(response)
                hasFinalResults = true
            })
            .disposed(by: self.disposeBag)
        if useCache {
            storeRepository.getPersons()
                .subscribe(onNext: { persons in
                    if !hasFinalResults {
                        let simulatedResponse = ServerResponse<[Person]>(data: persons)
                        relay.onNext(simulatedResponse)
                    }
                })
                .disposed(by: self.disposeBag)
        }

        return relay.asObservable()
    }

    func getPersons(fromIndex start: Int) -> Observable<ServerResponse<[Person]>> {
        return networkRepository.getPersons(start: start)
    }

}
