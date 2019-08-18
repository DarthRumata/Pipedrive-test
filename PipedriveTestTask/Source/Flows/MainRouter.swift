//
//  MainRouter.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import UIKit

class MainRouter {

    private unowned let window: UIWindow
    private weak var splitController: UISplitViewController!
    private weak var listNavigation: UINavigationController!
    private weak var detailsController: PersonDetailViewController!

    init(window: UIWindow) {
        self.window = window
    }

    func startFlow() {
        splitController = MainViewController.instantiate()
        let listController = PersonListViewController.instantiate()
        let listNavigation = UINavigationController(rootViewController: listController)
        listController.viewModel = PersonsListViewModel(
            personsService: PersonsService(
                storeRepository: PersonsStoreRepository(storeService: StoreService.shared),
                networkRepository: PersonsNetworkRepository(networkService: NetworkService.shared)
            ),
            router: self
        )
        let detailsController = PersonDetailViewController.instantiate()
        let detailsViewModel = PersonDetailViewModel(person: listController.viewModel.output.selectedPerson)
        detailsController.viewModel = detailsViewModel

        splitController.viewControllers = [listNavigation, detailsController]

        window.rootViewController = splitController
        window.makeKeyAndVisible()
        self.listNavigation = listNavigation
        self.detailsController = detailsController
    }

    func showPersonDetails() {
        listNavigation.showDetailViewController(detailsController, sender: nil)
    }

}
