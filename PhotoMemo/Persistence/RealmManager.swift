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
    static let shared = RealmManager()
    
    private let realm = try! Realm()
    
    func saveData<T: Object>(data: T) {
        try! realm.write {
            realm.add(data)
        }
    }
    
    func loadData<T: Object>(_: T.Type) -> Results<T> {
        return realm.objects(T.self)
    }
}
