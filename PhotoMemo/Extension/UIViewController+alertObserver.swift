//
//  UIViewController+alertObserver.swift
//  PhotoMemo
//
//  Created by GH Choi on 2021/03/01.
//

import UIKit
import RxSwift

extension UIViewController {
    func alertObserver(title: String, message: String) -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction =  UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func alertAskObserver(title: String, message: String) -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction =  UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            let cancelAction =  UIAlertAction(title: "취소", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
