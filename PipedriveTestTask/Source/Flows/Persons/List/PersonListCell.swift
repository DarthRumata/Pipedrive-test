//
//  PersonListCell.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import UIKit
import Reusable

class PersonListCell: UITableViewCell, NibReusable {

    @IBOutlet weak var nameLabel: UILabel!

    func configure(with person: Person) {
        nameLabel.text = person.name
    }
}
