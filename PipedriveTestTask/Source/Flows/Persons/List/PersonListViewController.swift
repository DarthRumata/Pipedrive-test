//
//  MasterViewController.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import UIKit
import CoreData
import RxDataSources
import RxSwift
import Reusable
import SVProgressHUD

struct DefaultSection<Item>: SectionModelType {

    private(set) var items: [Item]

    init(items: [Item]) {
        self.items = items
    }

    init(original: DefaultSection, items: [Item]) {
        self = original
        self.items = items
    }

}

class PersonListViewController: UITableViewController, StoryboardSceneBased {

    static let sceneStoryboard = UIStoryboard(name: "PersonsFlow", bundle: nil)

    var detailViewController: PersonDetailViewController? = nil
    var viewModel: PersonsListViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Persons list"
        configureTableView()
        configureBindings()
    }

}

private extension PersonListViewController {

    func configureTableView() {
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.register(cellType: PersonListCell.self)
        tableView.register(cellType: LoadingMoreCell.self)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        let dataSource = createDataSource()
        viewModel.output.sections
            .do(onNext: { [weak self] _ in
                self?.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(viewModel.input.onPullToRefresh)
            .disposed(by: disposeBag)
        tableView.refreshControl  = refreshControl
    }

    func configureBindings() {
        tableView.rx.modelSelected(Person.self)
            .asDriver()
            .drive(viewModel.input.onSelectPerson)
            .disposed(by: disposeBag)
        tableView.rx.prefetchRows
            .asDriver()
            .map { $0.last?.row ?? 0 }
            .drive(viewModel.input.onScrollToRow)
            .disposed(by: disposeBag)
        viewModel.output.isLoading
            .drive(onNext: { isLoading in
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            })
            .disposed(by: disposeBag)
        viewModel.input.onLoadView.onNext(())
    }

    func createDataSource() -> RxReloadAwareDataSource<DefaultSection<CellDataSource>> {
        let datasource = RxReloadAwareDataSource<DefaultSection<CellDataSource>>(
            configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
                if let person = item as? Person {
                    let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PersonListCell.self)
                    cell.configure(with: person)
                    return cell
                } else if item is LoadingMoreMarker {
                    let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LoadingMoreCell.self)
                    return cell
                } else {
                    fatalError("Unknown dataSource")
                }
        })

        return datasource
    }

}

