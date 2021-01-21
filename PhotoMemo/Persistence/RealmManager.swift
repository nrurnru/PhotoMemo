//
//  RealmManager.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import Foundation
import RealmSwift

class RealmManager {
    private init(){}
    
    // memory leak 확인
    static let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    static let shared = RealmManager()
    
    private let realm = try! Realm(configuration: configuration)
    
    func saveData<T: Object>(data: T) {
        try! realm.write {
            realm.add(data)
        }
    }
    
    func loadData<T: Object>(_: T.Type) -> Results<T> {
        return realm.objects(T.self)
    }
    
    func updateMemo(memo: Memo, text: String) {
        try! realm.write {
            memo.text = text
            memo.updatedAt = Date()
            if memo.isAdded == false { // 메모를 새로 작성하는 경우가 먼저 동기화되기 때문에 불필요함
                memo.isUpdated = true
            }
            realm.add(_ : memo, update: .error)
        }
    }
    
    func deleteData<T: Object>(data: T) {
        try! realm.write {
            realm.delete(data)
        }
    }
    
    func deleteDataList<T: Object>(dataList: [T]) {
        try! realm.write {
            realm.delete(dataList)
        }
    }
    
    func fetchCreatedMemo() -> [Memo] {
        var lastSyncDate = Date(timeIntervalSince1970: 0)
        if let lastSyncedString = UserDefaults.standard.string(forKey: "lastSynced") {
            lastSyncDate = ISO8601DateFormatter().date(from: lastSyncedString) ?? lastSyncDate
        }
        
        let createdMemos = realm.objects(Memo.self).filter("createdAt > %@", lastSyncDate)
        return Array(createdMemos)
    }
    
    func fetchUpdatedMemo() -> [Memo] {
        var lastSyncDate = Date(timeIntervalSince1970: 0)
        if let lastSyncedString = UserDefaults.standard.string(forKey: "lastSynced") {
            lastSyncDate = ISO8601DateFormatter().date(from: lastSyncedString) ?? lastSyncDate
        }
        
        let updatedMemos = realm.objects(Memo.self).filter("updatedAt > %@", lastSyncDate)
        return Array(updatedMemos)
    }
}
