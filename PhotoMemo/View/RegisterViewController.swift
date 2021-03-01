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
        bindOutput()
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
    
    func bindOutput() {
        viewModel.registerResult.bind { result in
            switch result {
            case .success(_):
                self.alertObserver(title: "가입 완료", message: "가입이 완료되었습니다.").bind { _ in
                    self.viewModel.registerComplete.accept(true)
                }.disposed(by: self.disposeBag)
            case .failure(_):
                self.alertObserver(title:  "오류", message: "이미 존재하는 아이디입니다.").bind { _ in
                    self.viewModel.registerComplete.accept(false)
                }.disposed(by: self.disposeBag)
            }
        }.disposed(by: disposeBag)
    }
}
