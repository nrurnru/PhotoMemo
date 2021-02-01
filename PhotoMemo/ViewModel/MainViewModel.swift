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
    let isEditmode = PublishRelay<Bool>()
    let syncButtonTapped = PublishRelay<Void>()
    let logoutButtonTapped = PublishRelay<Void>()
    
    let selectedMemoForDelete = PublishRelay<Memo>()
    let deselectedMemoForDelete = PublishRelay<Memo>()
    
    //vm -> view
    let data = ReplayRelay<Results<Memo>>.create(bufferSize: 1)
    let logoutSuccessed = PublishRelay<Bool>()
    let deleteCompleted = PublishRelay<Bool>()
    let syncCompleted = PublishRelay<Bool>()
    let newMemo = PublishRelay<Bool>()
    
    //?
    var selectedMemo = [Memo]()
    
    
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

        isEditmode.bind { isEditing in
            if isEditing {
                //do nothing?
            } else {
                // 삭제처리 실행
                self.deleteMemo()
            }
            
        }.disposed(by: disposeBag)
        
        syncButtonTapped.bind { _ in
            
            self.deleteCompleted.accept(true)
        }.disposed(by: disposeBag)
        
        //추가 제거
        selectedMemoForDelete.bind { memo in
            self.selectedMemo.append(memo)
        }.disposed(by: disposeBag)
        
        deselectedMemoForDelete.bind { memo in
            let index = self.selectedMemo.firstIndex(of: memo)
            self.selectedMemo.remove(at: index!)
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
    
    private func deleteMemo() {
        var deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") as? [String] ?? []
        deletedMemoIDs.append(contentsOf: selectedMemo.map { $0.id })
        UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
        RealmManager.shared.deleteDataList(dataList: selectedMemo)
        selectedMemo.removeAll()
    }
}
