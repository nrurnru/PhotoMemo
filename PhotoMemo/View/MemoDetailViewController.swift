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
    
    var viewModel = MemoDetailViewModel(memo: Memo())
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
    }
    
    private func bindOutput() {
        viewModel.memoRelay
            .asDriver()
            .drive { memo in
                self.memoTextView.text = memo.text
            }.disposed(by: disposeBag)

        
        viewModel.memoSaved
            .asDriver(onErrorJustReturn: ())
            .drive { _ in
                self.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.memoDeleted
            .asDriver(onErrorJustReturn: ())
            .drive { _ in
                self.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.memoRelay
            .asDriver()
            .drive { memo in
                let url = URL(string: "https://i.imgur.com/E7zh51q.png")
                self.memoImage.kf.setImage(with: url)
            }.disposed(by: disposeBag)
    }
}
