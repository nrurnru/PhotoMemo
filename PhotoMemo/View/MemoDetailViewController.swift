//
//  MemoDetailViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RxSwift
import RxCocoa

class MemoDetailViewController: UIViewController {

    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var memoImageView: UIImageView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var memoScrollView: UIScrollView!
    @IBOutlet weak var keyboardRegionHeight: NSLayoutConstraint!
    
    var viewModel: MemoDetailViewModel!
    private var disposeBag = DisposeBag()
    private let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
        setupUI()
        setGesture()
        
        picker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNotification()
        removeNotification()
    }
    
    private func bindInput(){
        deleteButton.rx.tap
            .bind(to: viewModel.deleteButtonTapped)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTapped)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text.orEmpty.distinctUntilChanged()
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
                if let url = URL(string: memo.imageURL) {
                    self.memoImageView.kf.setImage(with: url)
                }
                self.memoTextView.text = memo.text
            }.disposed(by: disposeBag)

        viewModel.deleteButtonTapped.bind{ _ in
            self.alertAskObserver(title: "메모 삭제", message: "이 메모를 삭제하시겠습니까?")
                .bind(to: self.viewModel.memoDeleteAction)
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.cancelAfterMemoHasEdited.bind { _ in
            self.alertAskObserver(title: "수정 취소", message: "메모 수정을 취소하시겠습니까?")
                .bind(to: self.viewModel.memoCancelAction)
            .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.saveButtonTapped.bind { _ in
            self.alertAskObserver(title: "수정 확인", message: "수정된 메모를 저장하시겠습니까?")
                .bind(to: self.viewModel.memoSaveAction)
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.hasTextOrImageChanged
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isLoadingIndicatorAnimating
            .bind(to: self.loadingIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        memoTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer()
        memoImageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind { recognizer in
            self.openLibrary()
        }.disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe { _ in
                self.view.endEditing(true)
                self.memoTextView.resignFirstResponder()
            }.disposed(by: disposeBag)
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offset = keyboardSize.height - view.safeAreaInsets.bottom
        keyboardRegionHeight.constant = offset
        view.layoutIfNeeded()
    }
    
    @objc private func keyboardWillHide() {
        keyboardRegionHeight.constant = 0
        view.layoutIfNeeded()
    }
}

extension MemoDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        viewModel.addedMemoImage.accept(image)
        memoImageView.image = image
        dismiss(animated: true)
    }
}
