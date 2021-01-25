//
//  LoginViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/25.
//

import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func loginAction(_ sender: Any) {
        guard let id = idTextField.text, let password = passwordTextField.text else { return }
        NetworkManager.shared.login(id: id, password: password) { [weak self] token in
            if let jwt = token {
                KeychainWrapper.standard.set(jwt, forKey: "jwt")
                self?.performSegue(withIdentifier: "loginSuccess", sender: nil)
            } else {
                //TODO: 로그인 실패 Alert 보여주기
                print("login failed.")
            }
        }
    }
}
