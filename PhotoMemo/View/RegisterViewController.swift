//
//  RegisterViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/25.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var registerButton: UIButton!
    
    private let disposeBag = DisposeBag()
    var viewModel: RegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
    }
    
    func bindInput() {
        registerButton.rx.tap
            .subscribe { _ in
                self.viewModel.registerButtonTapped.accept(())
            }.disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
        
        idTextField.rx.text.orEmpty
            .bind(to: viewModel.idField)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.pwField)
            .disposed(by: disposeBag)
    }
}
