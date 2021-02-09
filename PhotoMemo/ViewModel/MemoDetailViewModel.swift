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
    let memoText = BehaviorRelay<String?>(value: "")
    
    let saveButtonTapped = PublishRelay<Void>()
    let deleteButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    let memoSaved = PublishRelay<Void>()
    let memoDeleted = PublishRelay<Void>()
    let realm = try! Realm()
    
    init(memo: Memo, coordinator: SceneCoordinatorType, network: Network) {
        memoRelay.accept(memo)
        
        self.coordinator = coordinator
        self.network = network

        saveButtonTapped.map {[weak self] _ -> Memo in
            return (self?.memoRelay.value ?? Memo())
        }.subscribe(onNext: { [weak self] nextMemo in
            self?.modifyMemo(memo: nextMemo)
            self?.memoSaved.accept(())
        }).disposed(by: disposeBag)
        
        deleteButtonTapped.map {[weak self] _ -> Memo in
            return self?.memoRelay.value ?? Memo()
        }.subscribe(onNext: { [weak self] nextMemo in
            self?.registerDeletedMemo(memo: nextMemo)
            self?.realm.rx.delete().onNext(nextMemo)
            self?.memoDeleted.accept(())
        }).disposed(by: disposeBag)
        
        cancelButtonTapped.subscribe { _ in
            coordinator.close(animated: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func modifyMemo(memo: Memo) {
        realm.beginWrite()
        memo.text = memoText.value ?? ""
        memo.updatedAt = Date()
        memo.isUpdated = true
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
