//
//  SyncData.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/20.
//

import Foundation

class SyncData: Codable {
    private let createdMemos: [MemoAdapter]
    private let updatedMemos: [MemoAdapter]
    private let deletedMemoIDs: [String]
    private let lastSynced = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
    
    init(createdMemos: [MemoAdapter], updatedMemos: [MemoAdapter], deletedMemoIDs: [String]) {
        self.createdMemos = createdMemos
        self.updatedMemos = updatedMemos
        self.deletedMemoIDs = deletedMemoIDs
    }
    
    enum CodingKeys: String, CodingKey {
        case createdMemos = "created_memos"
        case updatedMemos = "updated_memos"
        case deletedMemoIDs = "deleted_memo_ids"
        case lastSynced = "last_synced"
    }
}
