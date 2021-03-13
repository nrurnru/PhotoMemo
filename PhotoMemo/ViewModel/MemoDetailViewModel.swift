//
//  MemoDetailViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/28.
//

import Foundation
import RxSwift
import RxRelay
import RxRealm
import RealmSwift

// MARK: 메모 디테일 보기
// 메모가 수정되었으면(이미지, 텍스트 중 어느 것이라도) 취소 버튼을 눌렀을 때 변경사항을 버릴 것인지 확인 동작
// 메모가 수정되었으면 저장 버튼 활성화 및 정말로 수정할 것인지 확인 동작
// 삭제 버튼 탭할때 삭제할 것인지 확인 동작

final class MemoDetailViewModel {
    private var disposeBag = DisposeBag()
    private let coordinator: SceneCoordinatorType
    private let network: Network
    private let realm = try! Realm()
    
    let memoRelay = BehaviorRelay<Memo>(value: Memo())
    let memoText = PublishRelay<String>()
    let addedMemoImage = PublishRelay<UIImage>()
    let isLoadingIndicatorAnimating = BehaviorRelay<Bool>(value: false)
    
    let saveButtonTapped = PublishRelay<Void>()
    let deleteButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    
    let memoDeleteAction = PublishRelay<AlertType>()
    let memoSaveAction = PublishRelay<AlertType>()
    let memoCancelAction = PublishRelay<AlertType>()
    let cancelAfterMemoHasEdited = PublishRelay<Void>()
    
    init(memo: Memo, coordinator: SceneCoordinatorType, network: Network) {
        memoRelay.accept(memo)
        
        self.coordinator = coordinator
        self.network = network
        
        memoDeleteAction.bind { action in
            switch action {
            case .ok:
                let nextMemo = self.memoRelay.value
                self.registerDeletedMemo(memo: nextMemo)
                self.realm.rx.delete().onNext(nextMemo)
                self.coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            case .cancel:
                break
            }
        }.disposed(by: disposeBag)
        
        cancelButtonTapped
            .withLatestFrom(hasTextOrImageChanged.startWith(false))
            .bind { hasChanged in
                if hasChanged {
                    self.cancelAfterMemoHasEdited.accept(())
                } else {
                    self.coordinator.close(animated: true)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                }
            }.disposed(by: disposeBag)
        
        // 메모 작성을 취소하시겠습니까?
        memoCancelAction.bind { action in
            switch action {
            case .ok:
                self.coordinator.close(animated: true)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            case .cancel:
                break
            }
        }.disposed(by: disposeBag)
        
        bindSaveAction()
    }
    
    func modifyMemo(memo: Memo, text: String? = nil, imageURL: String? = nil) {
        realm.beginWrite()
        memo.updatedAt = Date()
        memo.isUpdated = true
        if let text = text {
            memo.text = text
        }
        if let url = imageURL {
            memo.imageURL = url
        }
        do {
            try realm.commitWrite()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func registerDeletedMemo(memo: Memo) {
        var deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") as? [String] ?? []
        deletedMemoIDs.append(memo.id)
        UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
    }
    
    // 이미지 또는 텍스트 중 하나라도 방출되었을 때를 감시
    lazy var hasTextOrImageChanged: Observable<Bool> = {
        let text = memoText.skip(2)
            .map { str -> Bool in
                return true
            }
        let image = addedMemoImage
            .map { _ -> Bool in
                return true
            }
        return Observable.merge(text, image).share()
    }()
    
    // 이미지, 텍스트가 모두 방출되었을 때 내려보내기
    lazy var editedMemoInfo: Observable<(String, UIImage)> = {
        return Observable.combineLatest(memoText.skip(2), addedMemoImage).share()
    }()
    
    func bindSaveAction() {
        // 텍스트만 수정된 경우, 둘 다 수정되면 동작 중지
        memoSaveAction
            .withLatestFrom(memoText.skip(2)) { (action, text) -> (AlertType, String) in
                return (action, text)
            }.take(until: editedMemoInfo)
            .bind { (action, text) in
                switch action {
                case .ok:
                    self.modifyMemo(memo: self.memoRelay.value, text: text)
                    self.coordinator.close(animated: true).subscribe().disposed(by: self.disposeBag)
                case .cancel:
                    break
                }
            }.disposed(by: disposeBag)
        
        // 이미지만 수정된 경우, 둘 다 수정되면 동작 중지
        memoSaveAction
            .withLatestFrom(addedMemoImage) { (action, image) -> (AlertType, UIImage) in
                return (action, image)
            }.take(until: editedMemoInfo)
            .bind { (action, image) in
                switch action {
                case .ok:
                    self.isLoadingIndicatorAnimating.accept(true)
                    self.network.uploadImage(image: image)
                        .subscribe { (url) in
                            self.modifyMemo(memo: self.memoRelay.value, imageURL: url)
                            self.coordinator.close(animated: true).subscribe().disposed(by: self.disposeBag)
                        } onFailure: { (error) in
                            print(error.localizedDescription)
                        }.disposed(by: self.disposeBag)
                case .cancel:
                    break
                }
            }.disposed(by: disposeBag)
        
        // 둘 다 수정된 경우
        memoSaveAction
            .withLatestFrom(editedMemoInfo) { (action, memoInfo) -> (AlertType, (String, UIImage)) in
                return (action, memoInfo)
            }.bind { (action, memoInfo) in
                let (text, image) = memoInfo
                switch action {
                case .ok:
                    self.isLoadingIndicatorAnimating.accept(true)
                    self.network.uploadImage(image: image).subscribe { url in
                        self.modifyMemo(memo: self.memoRelay.value, text: text, imageURL: url)
                        self.coordinator.close(animated: true).subscribe().disposed(by: self.disposeBag)
                    } onFailure: { (error) in
                        print(error.localizedDescription)
                    }.disposed(by: self.disposeBag)
                case .cancel:
                    break
                }
            }.disposed(by: disposeBag)
    }
}
