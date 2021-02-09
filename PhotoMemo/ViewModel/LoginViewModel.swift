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
    let coordinator: SceneCoordinatorType
    let network = Network()
    private var disposeBag = DisposeBag()
    
    // 뷰 -> 뷰모델
    let idField = PublishRelay<String>()
    let pwField = PublishRelay<String>()
    let loginButtonTapped = PublishRelay<Void>()
    let registerButtonTapped = PublishRelay<Void>()
    
    init(coordinator: SceneCoordinatorType) {
        self.coordinator = coordinator
        
        let loginField = Observable.combineLatest(idField, pwField)
        loginField.subscribe().disposed(by: disposeBag)
        loginButtonTapped.withLatestFrom(loginField).bind { loginInfo in
            self.network.loginRelay.accept(loginInfo)
        }.disposed(by: disposeBag)
        
        network.loginSuccessed.bind { token in
            KeychainWrapper.standard.set(token, forKey: "jwt")
            coordinator.transition(to: .memoList(.init(coordinator: coordinator)), using: .push, animate: true).subscribe().disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        registerButtonTapped
            .subscribe { _ in
                coordinator.transition(to: .register(.init(coordinator: coordinator)) , using: .push, animate: true).subscribe().disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
    }
    
    // TODO: 로그인 검증 로직 적용
    private func idValidate(id: String) -> Bool {
        id.contains("@")
    }
    
    private func pwValidate(pw: String) -> Bool {
        pw.count > 5
    }
}
