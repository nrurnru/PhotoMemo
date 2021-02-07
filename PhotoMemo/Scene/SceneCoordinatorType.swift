//
//  SceneCoordinatorType.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/07.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType  {
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animate: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
}
