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
import Alamofire

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
    var upSyncRelay = PublishRelay<SyncData>()
    var downSyncRelay = PublishRelay<Bool>()
    
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
            self.syncStart()
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
        
        bindSyncData()
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
    
    func syncStart() {
        let updatedMemos = RealmManager.shared.fetchUpdatedMemo().map { MemoAdapter(memo: $0) }
        let deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") ?? []
        guard let d = deletedMemoIDs as? [String] else { return }
        let syncData = SyncData(updatedMemos: updatedMemos, deletedMemoIDs: d)
        upSyncRelay.accept(syncData)
    }
    
    func bindSyncData() {
        let baseURL = "http://nrurnru.pythonanywhere.com/memo/sync"
        
        func headers() -> HTTPHeaders {
            guard let jwt = KeychainWrapper.standard.string(forKey: "jwt") else { return [:] }
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "jwt": jwt
                ]
            return headers
        }
        
        func headers(id: String, password: String) -> HTTPHeaders {
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Userid" : id,
                "Userpassword": password
                ]
            return headers
        }
        
        upSyncRelay.bind { syncData in
            AF.request(baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default, headers: headers()).validate(statusCode:  Array(200..<300)).responseData { response in
                switch response.result {
                case .success:
                    self.downSyncRelay.accept(true)
                case .failure:
                    print("failed")
                }
            }
        }.disposed(by: disposeBag)
        
        downSyncRelay.bind { _ in
            let lastSynced: String = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
            let parameters: Parameters = [
                "last_synced": lastSynced
            ]
            
            AF.request(baseURL, parameters: parameters, encoding: URLEncoding.queryString, headers: headers()).responseJSON { response in
                switch response.result {
                case .success(let value):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let syncData = try JSONDecoder().decode(SyncData.self, from: jsonData)
                        syncData.updatedMemos.forEach { updatedMemo in
                            RealmManager.shared.saveData(data: updatedMemo.toMemo())
                            
                        }
                        RealmManager.shared.deleteDataWithIDs(Memo.self, deletedIDs: syncData.deletedMemoIDs)
                        UserDefaults.standard.set([], forKey: "deletedMemoIDs")
                        UserDefaults.standard.set(ISO8601DateFormatter().string(from: Date()), forKey: "lastSynced")
                        self.syncCompleted.accept(true)
                    } catch (let error){
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }.disposed(by: disposeBag)
    }
}
