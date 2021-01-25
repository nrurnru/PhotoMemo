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
        do {
            try realm.write {
                realm.add(data, update: .modified)
            }
        } catch (let error) {
            print(error.localizedDescription)
        }
        
    }
    
    func loadData<T: Object>(_: T.Type) -> Results<T> {
        return realm.objects(T.self)
    }
    
    func updateMemo(memo: Memo, text: String) {
        do {
            try realm.write {
                memo.text = text
                memo.updatedAt = Date()
                memo.isUpdated = true
                realm.add(_ : memo, update: .modified)
            }
        } catch (let error) {
            print(error.localizedDescription)
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
    
    func deleteDataWithIDs<T: Object>(_ type: T.Type, deletedIDs: [String]) {
        try! realm.write {
            let deleteObjects = realm.objects(T.self).filter("id in %@", deletedIDs)
            realm.delete(deleteObjects)
        }
    }
    
    func deleteAllData<T: Object>(_ type: T.Type) {
        try! realm.write {
            let allObjects = realm.objects(T.self)
            realm.delete(allObjects)
        }
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
