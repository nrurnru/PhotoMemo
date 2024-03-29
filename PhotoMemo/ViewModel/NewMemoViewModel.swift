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
import RxRealm

final class NewMemoViewModel {
    
    private var disposeBag = DisposeBag()
    let coordinator: SceneCoordinatorType
    let network: Network
    
    let textViewField = PublishRelay<String?>()
    let saveButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    let addedMemoImage = PublishRelay<UIImage?>()
    let imageURL = PublishRelay<String>()
    let isLoadingIndicatorAnimating = BehaviorRelay<Bool>(value: false)
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network
        
        saveButtonTapped.withLatestFrom(addedMemoImage.startWith(nil)).bind { image in
            if let image = image {
                self.isLoadingIndicatorAnimating.accept(true)
                self.network.uploadImage(image: image)
                    .subscribe { url in
                        self.imageURL.accept(url)
                    } onFailure: { error in
                        print(error.localizedDescription)
                    } onDisposed: {
                        self.isLoadingIndicatorAnimating.accept(false)
                    }
                    .disposed(by: self.disposeBag)
            } else {
                self.imageURL.accept("")
            }
        }.disposed(by: self.disposeBag)
        
        cancelButtonTapped.subscribe { _ in
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

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
