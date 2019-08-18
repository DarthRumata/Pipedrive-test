//
//  PersonDetailViewModel.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 12-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

extension PersonDetailViewModel {
    struct Input {

    }
    struct Output {
        let avatar: Driver<URL?>
        let name: Driver<String>
        let email: Driver<String?>
        let phone: Driver<String?>
        let showPlaceholder: Driver<Bool>
    }
}

class PersonDetailViewModel {

    let input: Input
    let output: Output

    private let personSubject = BehaviorSubject<Person?>(value: nil)
    private let disposeBag = DisposeBag()

    init(person: Driver<Person>) {
        input = Input()
        output = Output(
            avatar: personSubject.filterNil().map { $0.avatar?.source.medium }.asDriver(onErrorDriveWith: .never()),
            name: personSubject.filterNil().map { $0.name }.asDriver(onErrorDriveWith: .never()),
            email: personSubject.filterNil().map { $0.emails.first?.value }.asDriver(onErrorDriveWith: .never()),
            phone: personSubject.filterNil().map { $0.phones.first?.value }.asDriver(onErrorDriveWith: .never()),
            showPlaceholder: personSubject.map { $0 == nil }.asDriver(onErrorDriveWith: .never())
        )

        person
            .drive(personSubject)
            .disposed(by: disposeBag)
    }
}
