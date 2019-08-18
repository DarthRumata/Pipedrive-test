//
//  DetailViewController.swift
//  PipedriveTestTask
//
//  Created by Stas Kirichok on 10-08-2019.
//  Copyright © 2019 Stas Kirichok. All rights reserved.
//

import UIKit
import Reusable
import TweeTextField
import RxSwift
import RxCocoa
import RxKingfisher

class PersonDetailViewController: UIViewController, StoryboardSceneBased {

    static let sceneStoryboard = UIStoryboard(name: "PersonsFlow", bundle: nil)

    var viewModel: PersonDetailViewModel!

    private let disposeBag = DisposeBag()

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameField: TweeAttributedTextField!
    @IBOutlet weak var emailField: TweeAttributedTextField!
    @IBOutlet weak var phoneField: TweeAttributedTextField!
    private var placeholderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureBindings()
    }

}

private extension PersonDetailViewController {

    func configureView() {
        title = "Person"
        placeholderView = UIView(frame: .zero)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .white
        view.addSubview(placeholderView)
        placeholderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        placeholderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        let label = UILabel(frame: .zero)
        label.text = "Select person in list to view details"
        label.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor).isActive = true
    }

    func configureBindings() {
        viewModel.output.avatar
            .drive(onNext: { [weak self] url in
                self?.avatarView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"))
            })
            .disposed(by: disposeBag)
        viewModel.output.name
            .drive(nameField.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.email
            .drive(onNext: { [unowned self] text in
                self.emailField.isHidden = !(text?.isNotEmpty == true)
                self.emailField.text = text
            })
            .disposed(by: disposeBag)
        viewModel.output.phone
            .drive(onNext: { [unowned self] text in
                self.phoneField.isHidden = !(text?.isNotEmpty == true)
                self.phoneField.text = text
            })
            .disposed(by: disposeBag)
        viewModel.output.showPlaceholder
            .map { !$0 }
            .drive(placeholderView.rx.isHidden)
            .disposed(by: disposeBag)
    }

}

