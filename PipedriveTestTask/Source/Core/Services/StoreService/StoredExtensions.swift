//
//  StoredExtensions.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 16-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation

extension StoredPerson {

    var businessEntity: Person {
        return Person(
            id: id,
            name: name!,
            phones: (phones?.allObjects as? [StoredContactInfo])?.map { $0.businessEntity } ?? [],
            emails: (emails?.allObjects as? [StoredContactInfo])?.map { $0.businessEntity } ?? [],
            organizationName: organizationName,
            avatar: avatar?.businessEntity
        )
    }

}

extension StoredContactInfo {

    var businessEntity: ContactInfo {
        return ContactInfo(label: label!, value: value!, isPrimary: isPrimary)
    }

}

extension StoredPicture {

    var businessEntity: Picture {
        return Picture(id: id, isActive: isActive, source: source!.businessEntity)
    }

}

extension StoredSource {
    var businessEntity: Source {
        return Source(small: small!, medium: medium!)
    }
}
