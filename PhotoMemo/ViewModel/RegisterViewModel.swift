//
//  RegisterViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/08.
//

import Foundation
import RxSwift
import RxRelay

final class RegisterViewModel {
    private var disposeBag = DisposeBag()
    let coordinator: SceneCoordinatorType
    let network: Network
    
    let registerButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    let registerSuccessed = PublishRelay<Bool>()
    
    let idField = PublishRelay<String>()
    let pwField = PublishRelay<String>()
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network
        
        let registerField = Observable.combineLatest(idField, pwField)
        registerField.subscribe().disposed(by: disposeBag)
        registerButtonTapped.withLatestFrom(registerField).bind { registerInfo in
            self.network.register.accept(registerInfo)
        }.disposed(by: disposeBag)

        cancelButtonTapped.subscribe { _ in
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        network.registerSuccessed.bind { isRegisterSuccessed in
            if isRegisterSuccessed {
                coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            } else {
                print("register failed")
            }
        }.disposed(by: disposeBag)
    }
}
