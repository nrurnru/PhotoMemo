//
//  Memo.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import RealmSwift


class Memo: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var isSynced: Bool = false
}
