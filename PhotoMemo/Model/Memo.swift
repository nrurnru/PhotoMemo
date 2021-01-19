//
//  Memo.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import RealmSwift


class Memo: Object {
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

class MemoAdapter: Encodable {
    let formatter = ISO8601DateFormatter()
    
    init(memo: Memo) {
        self.number = memo.number
        self.text = memo.text
        self.createdAt = formatter.string(from: memo.createdAt)
        self.updatedAt = formatter.string(from: memo.updatedAt)
    }
    
    let user_id = 1
    let number: Int
    let text: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case number = "memo_number"
        case text
        case createdAt
        case updatedAt
    }
}
