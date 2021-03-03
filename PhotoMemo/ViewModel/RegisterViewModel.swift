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
    
    let registerComplete = PublishRelay<Bool>()
    let registerResult = PublishRelay<Result<Void, NetworkError>>()
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network
        
        registerField.bind { (id, pw) in
            self.network.register(id: id, pw: pw)
                .subscribe { isRegisterSuccessed in
                    if isRegisterSuccessed {
                        self.registerResult.accept(Result.success(()))
                    } else {
                        self.registerResult.accept(Result.failure(NetworkError.idAlreadyExists))
                    }
                } onFailure: { error in
                    self.registerResult.accept(Result.failure(NetworkError.serverError))
                }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        cancelButtonTapped.subscribe { _ in
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        registerComplete.bind { isCompleted in
            if isCompleted {
                coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
        }.disposed(by: disposeBag)
    }
    
    lazy var registerField: Observable<(String, String)> = {
        let registerField = Observable.combineLatest(idField, pwField)
        registerField.subscribe().disposed(by: disposeBag)
        return registerButtonTapped.withLatestFrom(registerField)
    }()
}
