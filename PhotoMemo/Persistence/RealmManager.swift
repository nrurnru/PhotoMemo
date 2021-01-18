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
}