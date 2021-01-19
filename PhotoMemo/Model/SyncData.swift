//
//  SyncData.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/20.
//

import Foundation

class SyncData: Codable {
    private let newMemos: [MemoAdapter]
    private let updatedMemos: [MemoAdapter]
    private let deletedMemoIDs: [String]
    
    init(newMemos: [MemoAdapter], updatedMemos: [MemoAdapter], deletedMemoIDs: [String]) {
        self.newMemos = newMemos
        self.updatedMemos = updatedMemos
        self.deletedMemoIDs = deletedMemoIDs
    }
    
    enum CodingKeys: String, CodingKey {
        case newMemos = "new_memos"
        case updatedMemos = "updated_memos"
        case deletedMemoIDs = "deleted_memo_ids"
    }
}
