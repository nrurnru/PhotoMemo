//
//  LoginViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/26.
//

import Foundation
import RxSwift
import RxRelay
import SwiftKeychainWrapper

final class LoginViewModel {
    private var disposeBag = DisposeBag()
    let coordinator: SceneCoordinatorType
    let network: Network
    
    // 뷰 -> 뷰모델
    let idField = PublishRelay<String>()
    let pwField = PublishRelay<String>()
    let loginButtonTapped = PublishSubject<Void>()
    let registerButtonTapped = PublishRelay<Void>()
    let isLoginSuccessed = PublishRelay<Bool>()
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network

        let loginField = Observable.combineLatest(idField, pwField)
        loginField.subscribe().disposed(by: disposeBag)
        loginButtonTapped.withLatestFrom(loginField).bind(to: network.loginRelay)
            .disposed(by: disposeBag)
        
        network.loginToken.bind { token in
            if let token = token {
                KeychainWrapper.standard.set(token, forKey: "jwt")
                coordinator.transition(to: .memoList(.init(coordinator: coordinator, network: network)), using: .push, animate: true).subscribe().disposed(by: self.disposeBag)
            } else {
                self.isLoginSuccessed.accept(false)
            }
        }.disposed(by: disposeBag)
    
        registerButtonTapped
            .subscribe { _ in
                coordinator.transition(to: .register(.init(coordinator: coordinator, network: network)) , using: .push, animate: true).subscribe().disposed(by: self.disposeBag)
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

enum AlertType {
    case ok
    case cancel
}
