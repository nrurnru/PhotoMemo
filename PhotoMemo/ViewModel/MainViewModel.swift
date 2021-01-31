//
//  MainViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import SwiftKeychainWrapper

final class MainViewModel {
    private var disposeBag = DisposeBag()
    
    //view -> vm
    let newMemoButtonTapped = PublishRelay<Void>()
    let deleteMemoButtonTapped = PublishRelay<Void>()
    let syncButtonTapped = PublishRelay<Void>()
    let logoutButtonTapped = PublishRelay<Void>()
    
    //vm -> view
    let data = ReplayRelay<Results<Memo>>.create(bufferSize: 1)
    let logoutSuccessed = PublishRelay<Bool>()
    let deleteCompleted = PublishRelay<Bool>()
    let syncCompleted = PublishRelay<Bool>()
    let newMemo = PublishRelay<Bool>()
    
    init() {
        self.fetchMemo().bind(to: data)
            .disposed(by: disposeBag)
        
        logoutButtonTapped.bind { _ in
            self.cleanData()
            self.logoutSuccessed.accept(true)
        }.disposed(by: disposeBag)

        newMemoButtonTapped.bind { _ in
            self.newMemo.accept(true)
        }.disposed(by: disposeBag)
        
        deleteMemoButtonTapped.bind { _ in
            
            self.deleteCompleted.accept(true)
        }.disposed(by: disposeBag)
        
        syncButtonTapped.bind { _ in
            
            self.deleteCompleted.accept(true)
        }.disposed(by: disposeBag)
        
    }
    
    private func cleanData() {
        UserDefaults.standard.removeObject(forKey: "lastSynced")
        KeychainWrapper.standard.remove(forKey: "jwt")
        RealmManager.shared.deleteAllData(Memo.self)
    }
    
    func fetchMemo() ->  Observable<Results<Memo>> {
        let realm = try! Realm()
        let result = realm.objects(Memo.self).sorted(byKeyPath: "createdAt", ascending: false)
        return Observable.collection(from: result)
    }
}
