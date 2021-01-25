//
//  LoginViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func loginAction(_ sender: Any) {
        // 로그인 검사 통과되면
        if true {
            performSegue(withIdentifier: "loginSuccess", sender: nil)
        } else {
            //TODO: 로그인 실패 Alert 보여주기
        }
    }
}
