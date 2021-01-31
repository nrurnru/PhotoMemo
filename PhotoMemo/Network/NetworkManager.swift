//
//  NetworkManager.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/20.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class NetworkManager {
    
    private init(){}
    static let shared = NetworkManager()
    
    private let baseURL = "http://nrurnru.pythonanywhere.com/memo/sync"
    
    private func headers() -> HTTPHeaders {
        guard let jwt = KeychainWrapper.standard.string(forKey: "jwt") else { return [:] }
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "jwt": jwt
            ]
        return headers
    }
    
    private func headers(id: String, password: String) -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Userid" : id,
            "Userpassword": password
            ]
        return headers
    }
    
    func downSync(completed: @escaping (_ syncData: SyncData) -> Void) {
        let lastSynced: String = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
        let parameters: Parameters = [
            "last_synced": lastSynced
        ]
        

        AF.request(baseURL, parameters: parameters, encoding: URLEncoding.queryString, headers: headers()).responseJSON { response in
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
        AF.request(baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default, headers: headers()).validate(statusCode:  Array(200..<300)).responseData { response in
            switch response.result {
            case .success:
                successed()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func register(id: String, password: String, successed: @escaping () -> Void) {
        AF.request("http://nrurnru.pythonanywhere.com/memo/login", method: .post, headers: headers(id: id, password: password)).validate(statusCode:  Array(200..<300)).responseData { response in
            switch response.result {
            case .success:
                successed()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
