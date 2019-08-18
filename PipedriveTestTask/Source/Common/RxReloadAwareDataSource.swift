//
//  RxReloadAwareDataSource.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 13-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

class RxReloadAwareDataSource<SectionType: SectionModelType>: RxTableViewSectionedReloadDataSource<SectionType> {

    var isReloadedData: Driver<[SectionType]> {
        return isReloadedDataSubject.asDriver(onErrorDriveWith: .never())
    }

    private let isReloadedDataSubject = PublishSubject<[SectionType]>()

    open override func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<Element>) {
        Binder(self) { [weak self] dataSource, element in
            dataSource.setSections(element)
            tableView.reloadData()
            self?.isReloadedDataSubject.onNext(element)
            }.on(observedEvent)
    }
}
