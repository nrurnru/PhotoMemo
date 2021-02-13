//
//  MemoDetailViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class MemoDetailViewController: UIViewController {

    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var memoImage: UIImageView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var viewModel: MemoDetailViewModel!
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func bindInput(){
        deleteButton.rx.tap
            .bind(to: viewModel.deleteButtonTapped)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTapped)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text.orEmpty
            .bind(to: viewModel.memoText)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.memoRelay
            .asDriver()
            .drive { memo in
                self.memoTextView.text = memo.text
            }.disposed(by: disposeBag)
        
        viewModel.memoRelay
            .asDriver()
            .drive { memo in
                let url = URL(string: memo.imageURL)
                self.memoImage.kf.setImage(with: url)
            }.disposed(by: disposeBag)
        
        viewModel.deleteButtonTapped.bind(onNext: { _ in
            self.deleteAlert().bind(to: self.viewModel.memoDeleteAction).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
}

extension MemoDetailViewController {
    private func deleteAlert() -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: "삭제 확인", message: "이 메모를 삭제하시겠습니까?", preferredStyle: .alert)
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
