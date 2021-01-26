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
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    private func bindUI() {
        loginButton.rx.tap.bind {[weak self] in
            self?.tabButton()
        }.disposed(by: disposeBag)
    }
    
    private func tabButton() {
        guard let id = idTextField.text, let pw = passwordTextField.text else { return }
        viewModel.myLogin(id: id, pw: pw).subscribe (
            onNext:  { success in
                if success {
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                }
            }, onError: { error in
                print(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
}
