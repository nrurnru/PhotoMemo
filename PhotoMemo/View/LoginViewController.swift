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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UIScrollView!
    
    private let disposeBag = DisposeBag()
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
        bindGesture()
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
        
        idTextField.rx.controlEvent(.editingDidBegin).bind { _ in
            self.scrollView.setContentOffset(self.titleLabel.frame.origin, animated: true)
            }.disposed(by: disposeBag)
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
                        self.alertAskObserver(title: "오류", message: "아이디와 비밀번호를 확인해 주세요.")
                            .subscribe().disposed(by: self.disposeBag)
                    case .serverError:
                        self.alertAskObserver(title: "오류", message: "이미 존재하는 아이디입니다.")
                            .subscribe().disposed(by: self.disposeBag)
                    default:
                        self.alertAskObserver(title: "오류", message: "알 수 없는 오류가 발생했습니다.")
                            .subscribe().disposed(by: self.disposeBag)
                    }
                }
        }.disposed(by: disposeBag)
    }
    
    private func bindGesture() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind { _ in
            self.view.endEditing(true)
        }.disposed(by: disposeBag)
    }
}
