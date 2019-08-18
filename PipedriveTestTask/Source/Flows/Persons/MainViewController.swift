//
//  MainViewController.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import Foundation
import UIKit
import Reusable

class MainViewController: UISplitViewController, StoryboardSceneBased {
    static let sceneStoryboard = UIStoryboard(name: "PersonsFlow", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }
}

extension MainViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
