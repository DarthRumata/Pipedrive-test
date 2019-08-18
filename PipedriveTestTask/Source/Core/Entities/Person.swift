//
//  Person.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import CoreData

struct Person: Decodable, Storable, CellDataSource {

    static let managedClassName: String = "Person"

    let id: Double
    let name: String
    let phones: [ContactInfo]
    let emails: [ContactInfo]
    let organizationName: String?
    let avatar: Picture?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case phones = "phone"
        case emails = "email"
        case organizationName = "org_name"
        case avatar = "picture_id"
    }

     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Double.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        organizationName = try container.decodeIfPresent(String.self, forKey: .organizationName)
        do {
            phones = try container.decode([FailableDecodable<ContactInfo>].self, forKey: .phones).compactMap { $0.base }
        } catch let error {
            print(error)
            phones = []
        }
        do {
            emails = try container.decode([FailableDecodable<ContactInfo>].self, forKey: .emails).compactMap { $0.base }
        } catch let error {
            print(error)
            emails = []
        }
        avatar = try container.decodeIfPresent(Picture.self, forKey: .avatar)
    }

    init(id: Double, name: String, phones: [ContactInfo], emails: [ContactInfo], organizationName: String?, avatar: Picture?) {
        self.id = id
        self.name = name
        self.phones = phones
        self.emails = emails
        self.organizationName = organizationName
        self.avatar = avatar
    }

}

extension Person {
    func managedObject(in context: NSManagedObjectContext) -> NSManagedObject {
        let object = NSEntityDescription.insertNewObject(forEntityName: Person.managedClassName, into: context) as! StoredPerson
        object.id = id
        object.name = name
        object.organizationName = organizationName
        object.avatar = avatar?.managedObject(in: context)
        object.addToPhones(NSSet(array: phones.map { $0.managedObject(in: context) }))
        object.addToEmails(NSSet(array: emails.map { $0.managedObject(in: context) }))

        return object
    }
}

struct ContactInfo: Decodable, Storable {

    static let managedClassName: String = "ContactInfo"

    let label: String
    let value: String
    let isPrimary: Bool

    private enum CodingKeys: String, CodingKey {
        case label
        case value
        case isPrimary = "primary"
    }

    func managedObject(in context: NSManagedObjectContext) -> StoredContactInfo {
        let object = NSEntityDescription.insertNewObject(forEntityName: ContactInfo.managedClassName, into: context) as! StoredContactInfo
        object.label = label
        object.value = value
        object.isPrimary = isPrimary

        return object
    }

}

struct Picture: Decodable, Storable {

    static let managedClassName: String = "Picture"

    let id: Double
    let isActive: Bool
    let source: Source

    private enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case isActive = "active_flag"
        case source = "pictures"
    }

    func managedObject(in context: NSManagedObjectContext) -> StoredPicture {
        let object = NSEntityDescription.insertNewObject(forEntityName: Picture.managedClassName, into: context) as! StoredPicture
        object.id = id
        object.isActive = isActive
        object.source = source.managedObject(in: context)

        return object
    }
}

struct Source: Decodable, Storable {

    static let managedClassName: String = "Source"

    let small: URL
    let medium: URL

    private enum CodingKeys: String, CodingKey {
        case small = "128"
        case medium = "512"
    }

    func managedObject(in context: NSManagedObjectContext) -> StoredSource {
        let object = NSEntityDescription.insertNewObject(forEntityName: Source.managedClassName, into: context) as! StoredSource
        object.small = small
        object.medium = medium

        return object
    }
}
