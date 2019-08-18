//
//  PersonsListViewModel.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension PersonsListViewModel {
    struct Input {
        let onSelectPerson: AnyObserver<Person>
        let onLoadView: AnyObserver<Void>
        let onScrollToRow: AnyObserver<Int>
        let onPullToRefresh: AnyObserver<Void>
    }
    struct Output {
        let sections: Driver<[DefaultSection<CellDataSource>]>
        let selectedPerson: Driver<Person>
        let isLoading: Driver<Bool>
    }
}

private let loadMoreThreshold: Int = 0

class PersonsListViewModel {

    let input: Input
    let output: Output

    // Dependencies
    private let personsService: PersonsService
    private unowned let router: MainRouter

    // Handlers
    private let selectedPersonRelay = PublishSubject<Person>()
    private let reloadPersonsHandler = PublishSubject<Bool>()
    private let scrollToRowHandler = PublishSubject<Int>()

    // State
    private let personsSubject = BehaviorSubject<[Person]>(value: [])
    private let disposeBag = DisposeBag()
    private var paginationSubject = BehaviorSubject<Pagination?>(value: nil)
    private let loadingSubject = BehaviorSubject<Bool>(value: false)
    private var isLoadingMore: Bool = false

    init(personsService: PersonsService, router: MainRouter) {
        self.personsService = personsService
        self.router = router

        input = Input(
            onSelectPerson: selectedPersonRelay.asObserver(),
            onLoadView: reloadPersonsHandler.asObserver().mapObserver { _ in return true },
            onScrollToRow: scrollToRowHandler.asObserver(),
            onPullToRefresh: reloadPersonsHandler.asObserver().mapObserver { _ in return false }
        )
        let sections: Driver<[DefaultSection<CellDataSource>]> = Observable.zip(personsSubject, paginationSubject)
            .asDriver(onErrorDriveWith: .never())
            .map { persons, pagination in
                var items: [CellDataSource] = persons
                if pagination?.hasMore == true {
                    items.append(LoadingMoreMarker())
                }

                return [DefaultSection(items: items)]
        }
        output = Output(
            sections: sections,
            selectedPerson: selectedPersonRelay.asDriver(onErrorDriveWith: .never()), 
            isLoading: loadingSubject.asDriver(onErrorDriveWith: .never()).skip(1)
        )

        configureBindings()
    }

    func fetchInitialPersons(useCache: Bool) {
        loadingSubject.onNext(true)
        personsService.getFirstPagePersons(useCache: useCache)
            .subscribe(onNext: { [weak self] response in
                self?.paginationSubject.onNext(response.pagination)
                self?.personsSubject.onNext(response.data)
                self?.loadingSubject.onNext(false)
            }, onError: { [weak self] error in
                self?.loadingSubject.onNext(false)
                print(error)
            })
            .disposed(by: disposeBag)
    }

    func loadMorePersons() {
        isLoadingMore = true
        let currentPagination = paginationSubject.unsafeValue()
        let newIndex = (currentPagination?.start ?? 0) + (currentPagination?.limit ?? 0)
        personsService.getPersons(fromIndex: newIndex)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.paginationSubject.onNext(response.pagination)
                var currentPersons = self.personsSubject.unsafeValue()
                currentPersons.append(contentsOf: response.data)
                self.personsSubject.onNext(currentPersons)
                self.isLoadingMore = false
            }, onError: { [weak self] error in
                self?.isLoadingMore = false
                print(error)
            })
        .disposed(by: disposeBag)
    }

}

private extension PersonsListViewModel {
    func configureBindings() {
        reloadPersonsHandler
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [unowned self] useCache in
                self.fetchInitialPersons(useCache: useCache)
            })
            .disposed(by: disposeBag)
        selectedPersonRelay
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [unowned self] _ in
                self.router.showPersonDetails()
            })
            .disposed(by: disposeBag)
        scrollToRowHandler
            .asDriver(onErrorDriveWith: .never())
            .filter { [unowned self] row in
                let isCloseToEndOfList = row >= self.personsSubject.unsafeValue().count
                let canLoadMore = self.paginationSubject.unsafeValue()?.hasMore == true
                let isLoading = self.loadingSubject.unsafeValue()
                return !isLoading && !self.isLoadingMore && canLoadMore && isCloseToEndOfList
            }
            .drive(onNext: { [unowned self] _ in
                self.loadMorePersons()
            })
            .disposed(by: disposeBag)
    }
}
