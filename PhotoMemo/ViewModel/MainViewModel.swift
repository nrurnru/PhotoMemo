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
    private let networkManager: Network
    
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
    
    var memoListForDelete = [Memo]()
    
    init() {
        self.networkManager = Network()
        
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
            if !isEditing {
                self.deleteMemo()
            }
        }.disposed(by: disposeBag)
        
        selectedMemoForDelete.bind { memo in
            self.memoListForDelete.append(memo)
        }.disposed(by: disposeBag)
        
        deselectedMemoForDelete.bind { memo in
            guard let index = self.memoListForDelete.firstIndex(of: memo) else { return }
            self.memoListForDelete.remove(at: index)
        }.disposed(by: disposeBag)
        
        syncButtonTapped.bind { _ in
            self.startSync()
        }.disposed(by: disposeBag)
        
        networkManager.downloadSuccessed.bind { result in
            self.syncCompleted.accept(result)
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
        deletedMemoIDs.append(contentsOf: memoListForDelete.map { $0.id })
        UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
        RealmManager.shared.deleteDataList(dataList: memoListForDelete)
        memoListForDelete.removeAll()
        self.deleteCompleted.accept(true)
    }
    
    func startSync() {
        let updatedMemos = RealmManager.shared.fetchUpdatedMemo().map { MemoAdapter(memo: $0) }
        let deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") ?? []
        guard let d = deletedMemoIDs as? [String] else { return }
        let syncData = SyncData(updatedMemos: updatedMemos, deletedMemoIDs: d)
        networkManager.upSyncRelay.accept(syncData)
    }
}
