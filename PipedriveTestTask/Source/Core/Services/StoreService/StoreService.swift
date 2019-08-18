//
//  StoreService.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 15-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

protocol Storable {

    associatedtype StoredClass: NSManagedObject

    static var managedClassName: String { get }

    func managedObject(in context: NSManagedObjectContext) -> StoredClass

}

class StoreService {

    static let shared = StoreService()

    private let persistentContainer: NSPersistentContainer
    private let mainContext: NSManagedObjectContext

    private init() {
        persistentContainer = StoreService.makePersistentContainer()
        mainContext = persistentContainer.viewContext
        mainContext.automaticallyMergesChangesFromParent = true
    }

    func executeRequest<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> Single<[T]> {
        return Single.create { [unowned self] observer -> Disposable in
            DispatchQueue.global().async {
                do {
                    let backgroundContext = self.persistentContainer.newBackgroundContext()
                    let objects = try backgroundContext.fetch(fetchRequest)
                    observer(.success(objects))
                } catch let error {
                    observer(.error(error))
                    print(error)
                }
            }

            return Disposables.create()
        }
    }

    func insert<T: Storable>(objects: [T]) -> Single<Void> {
        return Single.create { [unowned self] observer in
            DispatchQueue.global().async {
                let backgroundContext = self.persistentContainer.newBackgroundContext()
                backgroundContext.perform {
                    do {
                        objects.forEach { _ = $0.managedObject(in: backgroundContext) }
                        if backgroundContext.hasChanges {
                            try backgroundContext.save()
                        }
                        observer(.success(()))
                    } catch let error {
                        observer(.error(error))
                        print(error)
                    }
                    backgroundContext.reset()
                }
            }

            return Disposables.create()
        }
    }

    func deleteAll<T: Storable>(for type: T.Type) -> Single<Void> {
        return Single.create { [unowned self] observer in
            DispatchQueue.global().async {
                let backgroundContext = self.persistentContainer.newBackgroundContext()
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: T.managedClassName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try backgroundContext.execute(deleteRequest)
                    observer(.success(()))
                } catch let error {
                    observer(.error(error))
                    print(error)
                }
            }

            return Disposables.create()
        }
    }

    
}

private extension StoreService {

    static func makePersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "PipedriveTestTask")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }

    func saveContext () {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
