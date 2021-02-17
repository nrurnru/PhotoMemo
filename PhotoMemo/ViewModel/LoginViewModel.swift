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
    
    let idField = PublishRelay<String>()
    let pwField = PublishRelay<String>()
    let loginButtonTapped = PublishRelay<Void>()
    let loginResult = PublishSubject<Result<Void, NetworkError>>()
    let registerButtonTapped = PublishRelay<Void>()
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network

        startLogin().subscribe { (id, pw) in
            network.login(id: id, pw: pw)
                .subscribe { token in
                    // 로그인 실패 시에는 빈 문자열이 내려옴
                    if token.count > 0 {
                        KeychainWrapper.standard.set(token, forKey: "jwt")
                        coordinator.transition(to: .memoList(.init(coordinator: coordinator, network: network)), using: .push, animate: true).subscribe().disposed(by: self.disposeBag)
                    } else {
                        self.loginResult.onNext(Result.failure(NetworkError.unauthorized))
                    }
                } onFailure: { _ in
                    self.loginResult.onNext(Result.failure(NetworkError.serverError))
                }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        registerButtonTapped
            .subscribe { _ in
                coordinator.transition(to: .register(.init(coordinator: coordinator, network: network)) , using: .push, animate: true).subscribe().disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
    }
    
    private func startLogin() -> Observable<(String ,String)> {
        let loginField = Observable.combineLatest(idField, pwField)
        loginField.subscribe().disposed(by: disposeBag)
        return loginButtonTapped.withLatestFrom(loginField)
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
