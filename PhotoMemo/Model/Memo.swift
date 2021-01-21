//
//  Memo.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import RealmSwift


class Memo: Object {
    @objc dynamic var id: Int = Int.random(in: 1...10000)
    @objc dynamic var number: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var isAdded: Bool = true
    @objc dynamic var isUpdated: Bool = false
    @objc dynamic var isDeleted: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
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
    
    let id = Int.random(in: 1...1000)
    let userID = 1
    let number: String
    let text: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case number = "memo_number"
        case text
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toMemo() -> Memo {
        let memo = Memo()
        memo.number = self.number
        memo.text = self.text
        memo.createdAt = ISO8601DateFormatter().date(from: self.createdAt) ?? Date()
        memo.updatedAt = ISO8601DateFormatter().date(from: self.updatedAt) ?? Date()

        return memo
    }
}
