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

class MemoAdapter: Codable {
    let formatter = ISO8601DateFormatter()
    
    init(memo: Memo) {
        self.number = memo.number
        self.text = memo.text
        self.createdAt = formatter.string(from: memo.createdAt)
        self.updatedAt = formatter.string(from: memo.updatedAt)
    }
    
    let userID = 1
    let number: Int
    let text: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case number = "memo_number"
        case text
        case createdAt
        case updatedAt
    }
    
    // TEST
    init(number: Int, text: String, createdAt: String = ISO8601DateFormatter().string(from: Date()), updatedAt: String = ISO8601DateFormatter().string(from: Date())) {
        self.number = number
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
