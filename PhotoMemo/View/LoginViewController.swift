//
//  LoginViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/25.
//

import UIKit
import SwiftKeychainWrapper
import RxCocoa
import RxSwift
import RxAlamofire

class LoginViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    private let disposeBag = DisposeBag()
    var viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        loginButton.rx.tap
            .bind(to: viewModel.loginButtonTouched)
            .disposed(by: disposeBag)
        
        idTextField.rx.text.orEmpty
            .bind(to: viewModel.idField)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.pwField)
            .disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        viewModel.gotLoginToken
            .asDriver(onErrorJustReturn: true)
            .drive { value in
                if value {
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                }
            }.disposed(by: disposeBag)
    }
}
