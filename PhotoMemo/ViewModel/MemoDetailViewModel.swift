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

// MARK: 이미지 디테일 보기
// 메모가 수정되었으면(이미지, 텍스트 중 어느 것이라도) 취소 버튼을 눌렀을 때 변경사항을 버릴 것인지 확인 동작
// 메모가 수정되었으면 저장 버튼 활성화 및 정말로 수정할 것인지 확인 동작
// 삭제 버튼 탭할때 삭제할 것인지 확인 동작
//
//
//

final class MemoDetailViewModel {
        
    private var disposeBag = DisposeBag()
    let coordinator: SceneCoordinatorType
    let network: Network
    
    let memoRelay = BehaviorRelay<Memo>(value: Memo())
    let memoText = BehaviorRelay<String>(value: "")
    let addedMemoImage = BehaviorRelay<UIImage?>(value: nil)
    let isMemoEdited = BehaviorRelay<Bool>(value: false)
    
    let saveButtonTapped = PublishRelay<Void>()
    let deleteButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    
    let memoDeleteAction = PublishRelay<AlertType>()
    let memoSaveAction = PublishRelay<AlertType>()
    let memoCancelAction = PublishRelay<AlertType>()
    
    let cancelAfterMemoHasEdited = PublishRelay<Void>()
        
    let realm = try! Realm()
    
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
        
        cancelButtonTapped.bind { _ in
            if self.isMemoEdited.value {
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

        // 메모 수정 체크
        editMemoObserver()
            .skip(1) // 메모 텍스트가 원본, 이미지가 nil인 상태에서 한번 스킵, 이 이상 방출되면 메모가 수정된 것으로 간주
            .subscribe { _ in
            self.isMemoEdited.accept(true)
        }.disposed(by: disposeBag)
        
        // 메모 저장 알림이 표시된 이후 -> 이미지든 텍스트든 메모가 수정되었다는 뜻
        memoSaveAction.subscribe { action in
            switch action {
            case .ok:
                // 이미지가 변경되었으면
                if let image = self.addedMemoImage.value {
                    self.network.uploadImage(image: image).subscribe { url in
                        self.modifyMemo(memo: self.memoRelay.value, text: self.memoText.value, imageURL: url)
                    } onFailure: { error in
                        print(error.localizedDescription)
                    }.disposed(by: self.disposeBag)
                } else {
                    // 이미지가 nil 그대로이면 - 텍스트만 수정되었다는 뜻
                    self.modifyMemo(memo: self.memoRelay.value, text: self.memoText.value)
                }
                self.coordinator.close(animated: true).subscribe().disposed(by: self.disposeBag)
            case .cancel:
                // 아무 동작도 하지 않는다.
                break
            }
        } onError: { error in
            print(error.localizedDescription)
        }.disposed(by: disposeBag)
    }
    
    func modifyMemo(memo: Memo, text: String, imageURL: String? = nil) {
        realm.beginWrite()
        memo.text = text
        memo.updatedAt = Date()
        memo.isUpdated = true
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

    func editMemoObserver() -> Observable<(String, UIImage?)> {
        // BehaviorRelay의 기본값과 DB에서 가져올때 클래스명이 표시되어서 2번 스킵
        // 무조건 한번은 내려보내야 하기 때문에 다음 원본 메모값이 방출됨
        let text = memoText.asObservable().skip(2)
        let image = addedMemoImage.asObservable()
        
        return Observable.combineLatest(text, image)
    }
}
