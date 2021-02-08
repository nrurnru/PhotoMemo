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
    let upSyncRelay = PublishRelay<SyncData>()
    let downSyncRelay = PublishRelay<Bool>()
    let downloadSuccessed = PublishRelay<Bool>()
    let imageUpload = PublishRelay<UIImage>()
    let uploadedImageURL = PublishSubject<String>()
    let register = PublishRelay<(String, String)>()
    let registerSuccessed = PublishRelay<Bool>()
    
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
        case .login:
            let loginHeaders: HTTPHeaders = [
                "Accept": "application/json",
                "Userid" : id,
                "Userpassword": pw
            ]
            return loginHeaders
        }
    }
    
    init() {
        bindSync()
        bindRegister()
        bindImageUpload()
    }
    
    private func bindRegister() {
        register.bind { (id, pw) in
            AF.request("http://nrurnru.pythonanywhere.com/memo/login", method: .post, headers: self.headers(type: .login, id: id, pw: pw)).validate(statusCode:  Array(200..<300)).responseData { response in
                switch response.result {
                case .success:
                    self.registerSuccessed.accept(true)
                case .failure(_):
                    self.registerSuccessed.accept(false)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindSync() {
        upSyncRelay.bind { syncData in
            AF.request(self.baseURL, method: .post, parameters: syncData, encoder: JSONParameterEncoder.default, headers: self.headers(type: .memo)).validate(statusCode:  Array(200..<300)).responseData { response in
                switch response.result {
                case .success:
                    self.downSyncRelay.accept(true)
                case .failure:
                    print("failed")
                }
            }
        }.disposed(by: disposeBag)
        
        downSyncRelay.bind { _ in
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
                        self.saveSyncedData(syncData: syncData)
                        self.downloadSuccessed.accept(true)
                    } catch (let error){
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindImageUpload() {
        imageUpload.bind { image in
            let imageData = image.pngData()
            let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
            guard let utf8EncodedImage = base64Image?.data(using: .utf8) else { return }
            
            let multipartFormData = MultipartFormData()
            multipartFormData.append(utf8EncodedImage, withName: "image")
            
            AF.upload(multipartFormData: multipartFormData, to: self.imageServerURL, method: .post, headers: self.headers(type: .image)).response { response in
                switch response.result {
                case .success(let data):
                    guard let data = data, let uploadedURL = JSON(data)["data"]["link"].rawString() else {
                        self.uploadedImageURL.onError(NetworkError.parsingError)
                        return
                    }
                    self.uploadedImageURL.onNext(uploadedURL)
                case .failure(let error):
                    self.uploadedImageURL.onError(error)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    private func saveSyncedData(syncData: SyncData) {
        syncData.updatedMemos.forEach { updatedMemo in
            RealmManager.shared.saveData(data: updatedMemo.toMemo())
        }
        RealmManager.shared.deleteDataWithIDs(Memo.self, deletedIDs: syncData.deletedMemoIDs)
        UserDefaults.standard.set([], forKey: "deletedMemoIDs")
        UserDefaults.standard.set(ISO8601DateFormatter().string(from: Date()), forKey: "lastSynced")
    }
}

enum HTTPHeaderType {
    case memo
    case image
    case login
}

enum NetworkError: Error {
    case parsingError
    case serverError
}
