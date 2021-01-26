//
//  LoginViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/26.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON

class LoginViewModel {
    private func headers(id: String, password: String) -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Userid" : id,
            "Userpassword": password
            ]
        return headers
    }
    
    func myLogin(id: String, pw: String) -> Observable<Bool> {
        return RxAlamofire
            .requestJSON(.get, "http://localhost:8000/users/login", headers: headers(id: id, password: pw))
            .map { (response, any) -> Bool in
                guard let dict = any as? [String: String] else { return false }
                guard let token = dict["token"] else { return false }
                KeychainWrapper.standard.set(token, forKey: "jwt")
                return true
            }
    }
    
    // TODO: 로그인 검증 로직 적용
    func idValidate(id: String) -> Bool {
        id.contains("@")
    }
    
    func pwValidate(pw: String) -> Bool {
        pw.count > 5
    }
}
