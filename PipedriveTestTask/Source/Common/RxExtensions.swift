//
//  RxExtensions.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 18-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxSwift

extension BehaviorSubject {

    func unsafeValue() -> Element {
        return try! value()
    }

}
