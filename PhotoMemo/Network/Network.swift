//
//  ReactiveObserver.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/03.
//

import Foundation
import RxRelay
import RxSwift
import Alamofire
import SwiftKeychainWrapper

class Network {
    let upSyncRelay = PublishRelay<SyncData>()
    let downSyncRelay = PublishRelay<Bool>()
    let downloadSuccessed = PublishRelay<Bool>()
    
    private var disposeBag = DisposeBag()
    private let baseURL = "http://nrurnru.pythonanywhere.com/memo/sync"
    
    private func headers() -> HTTPHeaders {
        guard let jwt = KeychainWrapper.standard.string(forKey: "jwt") else { return [:] }
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "jwt": jwt
            ]
        return headers
    }
    
    init(){
        bindSync()
    }
    
    private func bindSync() {
        upSyncRelay.bind { syncData in
            AF.request(self.baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default, headers: self.headers()).validate(statusCode:  Array(200..<300)).responseData { response in
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
            
            AF.request(self.baseURL, parameters: parameters, encoding: URLEncoding.queryString, headers: self.headers()).responseJSON { response in
                switch response.result {
                case .success(let value):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let syncData = try JSONDecoder().decode(SyncData.self, from: jsonData)
                        self.saveSyncedData(syncData: syncData)
                        self.downloadSuccessed.accept(true)
                    } catch (let error){
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
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
