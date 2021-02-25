//
//  MemoDetailViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/28.
//

import Foundation
import RxSwift
import RxRelay
import RxRealm
import RealmSwift

final class MemoDetailViewModel {
        
    private var disposeBag = DisposeBag()
    let coordinator: SceneCoordinatorType
    let network: Network
    
    let memoRelay = BehaviorRelay<Memo>(value: Memo())
    let memoText = BehaviorRelay<String>(value: "")
    
    let saveButtonTapped = PublishRelay<Void>()
    let deleteButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    let memoDeleteAction = PublishRelay<AlertType>()
    let addedMemoImage = BehaviorRelay<UIImage?>(value: nil)
    let memoModified = BehaviorSubject<Bool>(value: false)
    
    let realm = try! Realm()
    
    init(memo: Memo, coordinator: SceneCoordinatorType, network: Network) {
        memoRelay.accept(memo)
        
        self.coordinator = coordinator
        self.network = network

        saveButtonTapped.map { _ -> Memo in
            return (self.memoRelay.value)
        }.subscribe(onNext: { nextMemo in
            guard let image = self.addedMemoImage.value else {
                self.modifyMemo(memo: nextMemo)
                self.coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
                return
            }
            self.network.uploadImage(image: image).subscribe { url in
                self.modifyMemo(memo: nextMemo, imageURL: url)
                self.coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            } onFailure: { error in
                print(error.localizedDescription)
            }.disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        cancelButtonTapped.subscribe { _ in
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        memoDeleteAction.bind { action in
            switch action {
            case .ok:
                let nextMemo = self.memoRelay.value
                self.registerDeletedMemo(memo: nextMemo)
                self.realm.rx.delete().onNext(nextMemo)
                self.coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            case .cancel:
                break
            }
        }.disposed(by: disposeBag)
        
        memoText.subscribe { _ in
            self.memoModified.onNext(true)
        }.disposed(by: disposeBag)
        
        addedMemoImage.subscribe { _ in
            self.memoModified.onNext(true)
        }.disposed(by: disposeBag)
    }
    
    func modifyMemo(memo: Memo, imageURL: String? = nil) {
        realm.beginWrite()
        memo.text = memoText.value
        memo.updatedAt = Date()
        memo.isUpdated = true
        if let url = imageURL {
            memo.imageURL = url
        }
        do {
            try realm.commitWrite()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func registerDeletedMemo(memo: Memo) {
        var deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") as? [String] ?? []
        deletedMemoIDs.append(memo.id)
        UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
    }
}
