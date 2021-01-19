//
//  Memo.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import RealmSwift


class Memo: Object, Codable {
    @objc dynamic var number: Int = Int()
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var isAdded: Bool = true
    @objc dynamic var isUpdated: Bool = false
    @objc dynamic var isDeleted: Bool = false
    
    override static func primaryKey() -> String? {
        return "number"
    }
}

