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
import Kingfisher

final class MainViewModel {
    private var disposeBag = DisposeBag()
    private let coordinator: SceneCoordinatorType
    private let network: Network
    
    //view -> vm
    let newMemoButtonTapped = PublishRelay<Void>()
    let syncButtonTapped = PublishRelay<Void>()
    let logoutButtonTapped = PublishRelay<Void>()
    let deleteButtonTapped = PublishRelay<Void>()
    let selectMemoForDetail = PublishRelay<Memo>()
    
    let selectedMemoForDelete = PublishRelay<Memo>()
    let deselectedMemoForDelete = PublishRelay<Memo>()
    let logoutAction = PublishRelay<AlertType>()
    let deleteAction = PublishRelay<AlertType>()
    
    //vm -> view
    let data = ReplayRelay<Results<Memo>>.create(bufferSize: 1)
    let askDeleteMemoAlert = PublishRelay<Void>()
    let memoDeleteMode = BehaviorRelay<Bool>(value: false)
    
    var memoListForDelete = [Memo]()
    
    init(coordinator: SceneCoordinatorType, network: Network) {
        self.coordinator = coordinator
        self.network = network
        
        self.fetchMemo().bind(to: data)
            .disposed(by: disposeBag)
        
        logoutAction.bind { action in
            switch action {
            case .ok:
                self.cleanData()
                self.coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            case .cancel:
                break
            }
        }.disposed(by: disposeBag)
        
        newMemoButtonTapped.subscribe { _ in
            self.coordinator.transition(to: .newMemo(.init(coordinator: coordinator, network: network)), using: .push, animate: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        selectMemoForDetail.subscribe { memo in
            coordinator.transition(to: .detail(.init(memo: memo, coordinator: coordinator, network: network)), using: .push, animate: true)
                .subscribe()
                .disposed(by: self.disposeBag)
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
        
        deleteAction.bind { action in
            switch action {
            case .ok:
                self.deleteMemo()
                self.memoDeleteMode.accept(false)
            case .cancel:
                break
            }
        }.disposed(by: disposeBag)
        
        deleteButtonTapped.bind { _ in
            if self.memoDeleteMode.value {
                // 삭제처리, 삭제할 메모가 없을 경우는 바로 선택모드 종료
                if self.memoListForDelete.count > 0 {
                    self.askDeleteMemoAlert.accept(())
                } else {
                    self.memoDeleteMode.accept(false)
                }
            } else {
                // 선택모드로 진입
                self.memoDeleteMode.accept(true)
            }
        }.disposed(by: disposeBag)
    }
    
    private func cleanData() {
        UserDefaults.standard.removeObject(forKey: "lastSynced")
        KeychainWrapper.standard.remove(forKey: "jwt")
        RealmManager.shared.deleteAllData(Memo.self)
        KingfisherManager.shared.cache.clearCache()
    }
    
    private func fetchMemo() ->  Observable<Results<Memo>> {
        let configure = Realm.Configuration.init(deleteRealmIfMigrationNeeded: true)
        let realm = try! Realm(configuration: configure)
        let result = realm.objects(Memo.self).sorted(byKeyPath: "createdAt", ascending: false)
        return Observable.collection(from: result)
    }
    
    private func deleteMemo() {
        var deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") as? [String] ?? []
        deletedMemoIDs.append(contentsOf: memoListForDelete.map { $0.id })
        UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
        RealmManager.shared.deleteDataList(dataList: memoListForDelete)
        memoListForDelete.removeAll()
    }
    
    func startSync() {
        let updatedMemos = RealmManager.shared.fetchUpdatedMemo().map { MemoAdapter(memo: $0) }
        let deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") ?? []
        guard let d = deletedMemoIDs as? [String] else { return }
        let syncData = SyncData(updatedMemos: updatedMemos, deletedMemoIDs: d)
        network.upSync(syncData: syncData).subscribe { isUpSyncSucceeded in
            if isUpSyncSucceeded {
                self.network.downSync().subscribe { syncData in
                    self.saveSyncedData(syncData: syncData)
                } onFailure: { error in
                    print(error.localizedDescription)
                }.disposed(by: self.disposeBag)
            }
        } onFailure: { error in
            print(error.localizedDescription)
        }.disposed(by: disposeBag)
    }
    
    private func saveSyncedData(syncData: SyncData) {
        syncData.updatedMemos.forEach { updatedMemo in
            RealmManager.shared.saveData(data: updatedMemo.toMemo())
        }
        RealmManager.shared.deleteDataWithIDs(Memo.self, deletedIDs: syncData.deletedMemoIDs)
        UserDefaults.standard.set([], forKey: "deletedMemoIDs")
        UserDefaults.standard.set(ISO8601DateFormatter().string(from: Date()), forKey: "lastSynced")
    }
}
