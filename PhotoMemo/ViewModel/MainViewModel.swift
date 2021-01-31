//
//  MainViewModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import Foundation
import RxSwift
import RxRelay

final class MainViewModel {
    
    //view -> vm
    let newMemoButtonTapped = PublishRelay<Void>()
    let deleteMemoButtonTapped = PublishRelay<Void>()
    let syncButtonTapped = PublishRelay<Void>()
    let logoutButtonTapped = PublishRelay<Void>()
    
    //vm -> view
    let data = PublishRelay<[Memo]>()
    
    
    init() {
        //Observable<[Memo]>.create
    }
    
    private func saveAction() {
        
    }
    
    private func deleteAction() {
        
    }
    
    private func logoutAction() {
        
    }
}
