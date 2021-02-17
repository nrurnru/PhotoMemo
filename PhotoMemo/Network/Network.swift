//
//  ReactiveObserver.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/03.
//

import Foundation
import RxRelay
import RxSwift
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON

class Network {
    private var disposeBag = DisposeBag()
    private let baseURL = "http://nrurnru.pythonanywhere.com/memo/sync"
    private let imageServerURL = "https://api.imgur.com/3/image"
    private let imageServerClientID = "65c533ea40c6a79"
    
    private func headers(type: HTTPHeaderType, id: String = "", pw: String = "") -> HTTPHeaders {
        switch type {
        case .memo:
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "jwt": KeychainWrapper.standard.string(forKey: "jwt") ?? ""
            ]
            return headers
        case .image:
            let imageHeaders: HTTPHeaders = [
                "Authorization": "Client-ID \(imageServerClientID)",
                "Content-Type": "multipart/form-data"
            ]
            return imageHeaders
        case .register:
            let registerHeaders: HTTPHeaders = [
                "Accept": "application/json",
                "Userid" : id,
                "Userpassword": pw
            ]
            return registerHeaders
        case .login:
            let loginHeaders: HTTPHeaders = [
                "Accept": "application/json",
                "Content-Type" :"application/json",
                "Userid" : id,
                "Userpassword": pw
            ]
            return loginHeaders
        }
    }
    
    func register(id: String, pw: String) -> Single<Bool> {
        return Single<Bool>.create { single -> Disposable in
            AF.request("http://nrurnru.pythonanywhere.com/memo/login", method: .post, headers: self.headers(type: .register, id: id, pw: pw))
                .validate(statusCode:  Array(200..<300))
                .responseData { response in
                switch response.result {
                case .success:
                    single(.success(true))
                case .failure(_):
                    single(.success(false))
                }
            }
            return Disposables.create()
        }
    }
    
    func login(id: String, pw: String) -> Single<String> {
        return Single<String>.create { single -> Disposable in
            AF.request("http://nrurnru.pythonanywhere.com/memo/login", method: .get, headers: self.headers(type: .login, id: id, pw: pw))
                .responseData { response in
                switch response.result {
                case .success(let json):
                    let token = JSON(json)["token"].stringValue
                    single(.success(token))
                case .failure:
                    single(.failure(NetworkError.serverError)) //서버문제
                }
            }
            return Disposables.create()
        }
    }
    
    func upSync(syncData: SyncData) -> Single<Bool> {
        return Single<Bool>.create { single -> Disposable in
            AF.request(self.baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default, headers: self.headers(type: .memo)).validate(statusCode: Array(200..<300)).responseData { response in
                switch response.result {
                case .success:
                    single(.success(true))
                case .failure:
                    single(.failure(NetworkError.serverError))
                }
            }
            return Disposables.create()
        }
    }
    
    func downSync() -> Single<SyncData> {
        return Single<SyncData>.create { single -> Disposable in
            let lastSynced: String = UserDefaults.standard.string(forKey: "lastSynced") ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
            
            let parameters: Parameters = [
                "last_synced": lastSynced
            ]
            
            AF.request(self.baseURL, parameters: parameters, encoding: URLEncoding.queryString, headers: self.headers(type: .memo)).responseJSON { response in
                switch response.result {
                case .success(let value):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let syncData = try JSONDecoder().decode(SyncData.self, from: jsonData)
                        single(.success(syncData))
                    } catch (let error){
                        single(.failure(error))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadImage(image: UIImage) -> Single<String> {
        Single<String>.create { single -> Disposable in
            let imageData = image.pngData()
            let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
            guard let utf8EncodedImage = base64Image?.data(using: .utf8) else {
                single(.failure(NetworkError.parsingError))
                return Disposables.create()
            }
            
            let multipartFormData = MultipartFormData()
            multipartFormData.append(utf8EncodedImage, withName: "image")
            
            AF.upload(multipartFormData: multipartFormData, to: self.imageServerURL, method: .post, headers: self.headers(type: .image)).response { response in
                switch response.result {
                case .success(let data):
                    guard let data = data, let uploadedURL = JSON(data)["data"]["link"].rawString() else {
                        single(.failure(NetworkError.parsingError))
                        return
                    }
                    single(.success(uploadedURL))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

enum HTTPHeaderType {
    case memo
    case image
    case login
    case register
}

enum NetworkError: Error {
    case unauthorized
    case parsingError
    case serverError
    case idAlreadyExists
}
