//
//  NewMemoViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RxSwift
import RxCocoa

class NewMemoViewController: UIViewController {
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var memoImageView: UIImageView!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var memoScrollView: UIScrollView!
    @IBOutlet weak var keyboardRegionHeight: NSLayoutConstraint!
    
    var viewModel: NewMemoViewModel!
    private var disposeBag = DisposeBag()
    private let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
        setupUI()
        setGesture()
        setDelegate()
        setNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification()
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
    }
    
    private func setDelegate() {
        picker.delegate = self
        memoTextView.delegate = self
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offset = keyboardSize.height - view.safeAreaInsets.bottom
        keyboardRegionHeight.constant = offset
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide() {
        keyboardRegionHeight.constant = 0
        self.view.layoutIfNeeded()
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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

extension NewMemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let bottomOffset = CGPoint(x: 0, y: memoScrollView.contentSize.height - memoScrollView.bounds.size.height)
        guard bottomOffset.y > 0 else { return }
        memoScrollView.setContentOffset(bottomOffset, animated: true)
    }
}
