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
    
    private let baseURL = "http://localhost:8000/users/sync"
    private let headers: HTTPHeaders = [
        //"Authorization": "user1",
        "Accept": "application/json"
        ]
    
    func downSync(completed: @escaping (_ syncData: SyncData) -> Void) {
        let lastSynced: String = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
        let parameters: Parameters = [
            "last_synced": lastSynced
        ]
        
        AF.request(baseURL, parameters: parameters, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let value):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    let syncData = try JSONDecoder().decode(SyncData.self, from: jsonData)
                    completed(syncData)
                } catch (let error){
                    print(error)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func upSync(syncData: SyncData) {
        AF.request(baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success:
                print("success")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
