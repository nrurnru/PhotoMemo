//
//  RegisterViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/25.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func registerAction(_ sender: UIButton) {
        guard let id = idTextField.text, let password = passwordTextField.text else { return }
        NetworkManager.shared.register(id: id, password: password) {[weak self] in
            // TODO: 로그인 화면 처리
            print("login success")
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
