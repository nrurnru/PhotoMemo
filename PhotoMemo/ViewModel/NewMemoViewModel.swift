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
    
    let textViewField = PublishRelay<String?>()
    let saveButtonTapped = PublishRelay<Void>()
    let memoSaved = PublishRelay<Void>()
    let addedMemoImage = BehaviorRelay<UIImage>(value: UIImage())
    let imageURL = PublishRelay<String>()
    
    init(){
        saveButtonTapped
            .bind { _ in
                self.network.imageUpload.accept(self.addedMemoImage.value)
            }.disposed(by: disposeBag)
        
        network.uploadedImageURL
            .bind(to: self.imageURL)
            .disposed(by: disposeBag)
        
        Observable.zip(saveButtonTapped, textViewField, imageURL).subscribe { (_, text, url) in
            self.saveMemo(text: text, url: url)
            self.memoSaved.accept(())
        }.disposed(by: disposeBag)
    }
    
    private func saveMemo(text: String?, url: String) {
        let memo = Memo()
        memo.text = text ?? ""
        memo.imageURL = url
        Realm.rx.add().onNext(memo)
    }
}