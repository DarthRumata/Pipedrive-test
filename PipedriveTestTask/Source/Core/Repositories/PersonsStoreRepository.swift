//
//  PersonsStoreRepository.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class PersonsStoreRepository {

    private let storeService: StoreService

    init(storeService: StoreService) {
        self.storeService = storeService
    }

    func getPersons() -> Observable<[Person]> {
        let fetchRequest = NSFetchRequest<StoredPerson>(entityName: Person.managedClassName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return storeService.executeRequest(fetchRequest)
            .map { storedPersons in
                return storedPersons.map { $0.businessEntity }
            }
            .asObservable()
    }

    func savePersons(_ persons: [Person]) -> Observable<Void> {
        return storeService.deleteAll(for: Person.self)
            .flatMap { _ in
                return self.storeService.insert(objects: persons)
            }
            .asObservable()
    }

}
