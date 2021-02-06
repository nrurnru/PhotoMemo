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
    let network = Network()
    
    let textViewField = BehaviorRelay<String?>(value: "")
    let saveButtonTapped = PublishRelay<Void>()
    let memoSaved = PublishRelay<Void>()
    
    init(){
        saveButtonTapped
            .map { [weak self] _ -> Memo in
                return self?.makeMemo() ?? Memo()
            }.subscribe(onNext: { [weak self] memo in
                Realm.rx.add().onNext(memo)
                self?.memoSaved.accept(())
            }).disposed(by: disposeBag)
        
    }
    
    private func makeMemo() -> Memo {
        let memo = Memo()
        memo.text = self.textViewField.value ?? ""
        return memo
    }
}
