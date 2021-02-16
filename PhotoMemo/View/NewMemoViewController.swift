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
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var memoImageView: UIImageView!
    @IBOutlet var loadingIndicatorView: UIView!
    
    var viewModel: NewMemoViewModel!
    private var disposeBag = DisposeBag()
    
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
        setGesture()
        picker.delegate = self
    }
    
    private func bindInput() {
        saveButton.rx.tap
            .bind {
                self.viewModel.textViewField.accept(self.memoTextView.text)
                self.viewModel.saveButtonTapped.accept(())
            }.disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: self.viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.addedMemoImage
            .bind(to: self.memoImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.saveButtonTapped.subscribe { _ in
            self.loadingIndicatorView.isHidden = false
            self.saveButton.isEnabled = false
        }.disposed(by: disposeBag)
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer()
        memoImageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind { recognizer in
            self.openLibrary()
        }.disposed(by: disposeBag)
    }
}

extension NewMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  else { return }
        viewModel.addedMemoImage.accept(image)
        memoImageView.image = image
        dismiss(animated: true)
    }
}
