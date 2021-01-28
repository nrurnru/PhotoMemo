//
//  NewMemoViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import CryptoSwift
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

class NewMemoViewController: UIViewController {
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    private let viewModel = NewMemoViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        memoTextView.rx.text.orEmpty
            .bind(to: viewModel.textViewField)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.memoSaved
            .bind { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
    }
}
