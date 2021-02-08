//
//  SceneCoordinator.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/07.
//

import Foundation
import RxSwift
import RxCocoa

class SceneCoordinator: SceneCoordinatorType {
    private var bag = DisposeBag()
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController! //돌아갈 동작
    }
    
    func transition(to scene: Scene, using style: TransitionStyle, animate: Bool) -> Completable {

        return Completable.create { completable -> Disposable in
            let target = scene.instantiate()
            
            switch style {
            case .root:
                self.window.rootViewController = target
                if let nav = target as? UINavigationController {
                    self.currentVC = nav.viewControllers.first!
                } else {
                    self.currentVC = target // 일반 뷰 컨트롤러를 루트 뷰로 사용할 경우
                }
                completable(.completed)
                
            case .push:
                guard let nav = self.currentVC.navigationController else {
                    completable(.error(TransitionError.navigationControllerMissing))
                    break
                }
                nav.pushViewController(target, animated: animate)
                self.currentVC = target
                completable(.completed)
                
            case .modal:
                self.currentVC.present(target, animated: animate) {
                    completable(.completed)
                }
                self.currentVC = target
            }
            return Disposables.create()
        }
    }
    
    func close(animated: Bool) -> Completable {
        return Completable.create { completable -> Disposable in
            if let presentingVC = self.currentVC.presentingViewController { // 모달인 경우
                presentingVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC
                    completable(.completed)
                }
            } else if let nav = self.currentVC.navigationController { // 네비게이션인 경우
                guard nav.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                self.currentVC = nav.viewControllers.last!
                completable(.completed)
                
            } else { // 루트뷰인데 닫을수 없음
                completable(.error(TransitionError.unknown))
            }
            return Disposables.create()
        }
    }
}
