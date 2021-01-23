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
        "Authorization": "1", //TODO: 로그인시 유저 토큰 받아오기
        "Accept": "application/json"
        ]
    
    func downSync(completed: @escaping (_ syncData: SyncData) -> Void) {
        let lastSynced: String = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
        let parameters: Parameters = [
            "last_synced": lastSynced
        ]
        
        AF.request(baseURL, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).responseJSON { response in
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
    
    func upSync(syncData: SyncData, successed: @escaping () -> Void) {
        AF.request(baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default, headers: headers).validate(statusCode:  Array(200..<300)).responseData { response in
            switch response.result {
            case .success:
                successed()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
