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
import RxRelay

final class LoginViewModel {
    private var disposeBag = DisposeBag()
    
    // 뷰 -> 뷰모델
    let idField = BehaviorRelay<String>(value: "")
    let pwField = BehaviorRelay<String>(value: "")
    
    // 뷰모델 -> 뷰
    let loginButtonTouched = PublishRelay<Void>()
    let gotLoginToken = PublishRelay<Bool>()
    
    init() {
        loginButtonTouched
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                return self?.loginSuccessed() ?? Observable.empty()
            }.subscribe { [weak self] value in
                self?.gotLoginToken.accept(value)
            }.disposed(by: disposeBag)
    }
    
    private func headers() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type" :"application/json",
            "Userid" : idField.value,
            "Userpassword": pwField.value
        ]
        return headers
    }
    
    private func loginSuccessed() -> Observable<Bool> {
        return json(.get, "http://nrurnru.pythonanywhere.com/memo/login", headers: headers())
            .map({ json -> Bool in
                let token = JSON(json)["token"].stringValue
                KeychainWrapper.standard.set(token, forKey: "jwt")
                return true
            })
    }
    
    // TODO: 로그인 검증 로직 적용
    private func idValidate(id: String) -> Bool {
        id.contains("@")
    }
    
    private func pwValidate(pw: String) -> Bool {
        pw.count > 5
    }
}
