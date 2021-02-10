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

class LoginViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    private let disposeBag = DisposeBag()
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        loginButton.rx.tap
            .bind(to: viewModel.loginButtonTapped)
            .disposed(by: disposeBag)
        
        idTextField.rx.text.orEmpty
            .bind(to: viewModel.idField)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.pwField)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .bind(to: viewModel.registerButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.loginResult
            .bind { result in
                switch result {
                case .success:
                    break
                case .failure(let networkError):
                    switch networkError {
                    case .unauthorized:
                        self.loginAlert(message: "아이디와 비밀번호를 확인해 주세요.").subscribe().disposed(by: self.disposeBag)
                    case .serverError:
                        self.loginAlert(message: "서버와의 연결에 실패했습니다.").subscribe().disposed(by: self.disposeBag)
                    default:
                        self.loginAlert(message: "알 수 없는 오류가 발생했습니다.").subscribe().disposed(by: self.disposeBag)
                    }
                }
        }.disposed(by: disposeBag)
    }
}

extension LoginViewController {
    private func loginAlert(message: String) -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
            let okAction =  UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
