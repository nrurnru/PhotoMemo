//
//  NewMemoViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/28.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import SwiftKeychainWrapper
import RxRealm

final class NewMemoViewModel {
    
    private var disposeBag = DisposeBag()
    let coordinator: SceneCoordinatorType
    let network: Network
    
    let textViewField = PublishRelay<String?>()
    let saveButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    let addedMemoImage = BehaviorRelay<UIImage>(value: UIImage())
    let imageURL = PublishRelay<String>()
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network
        
        saveButtonTapped
            .bind { _ in
                self.network.imageUpload.accept(self.addedMemoImage.value)
            }.disposed(by: disposeBag)
        
        cancelButtonTapped.subscribe { _ in
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        
        network.uploadedImageURL
            .bind(to: self.imageURL)
            .disposed(by: disposeBag)
        
        Observable.zip(saveButtonTapped, textViewField, imageURL).subscribe { (_, text, url) in
            self.saveMemo(text: text, url: url)
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    private func saveMemo(text: String?, url: String) {
        let memo = Memo()
        memo.text = text ?? ""
        memo.imageURL = url
        Realm.rx.add().onNext(memo)
    }
}
