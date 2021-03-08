//
//  Memo.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import RealmSwift
import SwiftKeychainWrapper
import CryptoSwift

class Memo: Object {
    @objc dynamic var id: String = Date().description.sha256()
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var isAdded: Bool = true
    @objc dynamic var isUpdated: Bool = false
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var imageURL: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MemoAdapter: Codable {
    let formatter = ISO8601DateFormatter()
    
    init(memo: Memo) {
        self.id = memo.id
        self.text = memo.text
        self.createdAt = formatter.string(from: memo.createdAt)
        self.updatedAt = formatter.string(from: memo.updatedAt)
        self.imageURL = memo.imageURL
    }
    
    let id: String
    let text: String
    let createdAt: String
    let updatedAt: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case imageURL = "image_url"
    }
    
    func toMemo() -> Memo {
        let memo = Memo()
        memo.id = self.id
        memo.text = self.text
        memo.createdAt = ISO8601DateFormatter().date(from: self.createdAt) ?? Date()
        memo.updatedAt = ISO8601DateFormatter().date(from: self.updatedAt) ?? Date()
        memo.imageURL = self.imageURL

        return memo
    }
}
