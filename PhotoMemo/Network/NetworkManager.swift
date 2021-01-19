//
//  NetworkManager.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/20.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    private init(){}
    static let shared = NetworkManager()
    
    private let baseURL = "http://localhost:8000/users/memo/"
    private let headers: HTTPHeaders = [
        //"Authorization": "user1",
        "Accept": "application/json"
        ]
    
    //TODO: sync로 변경
    func get() {
        AF.request(baseURL).responseString { response in
            switch response.result {
            case .success:
                let data = try! response.result.get()
                print(data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //TODO: sync로 변경
    func post(memo: Memo) {
        let testMemo = MemoAdapter(memo: memo)
        AF.request(baseURL, method: .post, parameters: testMemo, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func upSync(syncData: SyncData) {
        AF.request(baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func downSync() {
        AF.request(baseURL).responseString { response in
            switch response.result {
            case .success:
                let data = try! response.result.get()
                print(data)
                //return data, start DB sync
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
