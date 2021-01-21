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
    
    func downSync(completed: @escaping (_ json: JSON) -> Void) {
        let lastSynced: String = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
        AF.request("http://localhost:8000/users/sync/last_synced=\(lastSynced)").validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //return data, start DB sync
                completed(json)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func upSync(syncData: SyncData) {
        AF.request("http://localhost:8000/users/sync/", method: .post, parameters: syncData, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success:
                UserDefaults.standard.set(ISO8601DateFormatter().string(from: Date()), forKey: "lastSynced")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
