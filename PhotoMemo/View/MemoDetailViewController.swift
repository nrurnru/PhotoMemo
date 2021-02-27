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
    @IBOutlet var memoImageView: UIImageView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var viewModel: MemoDetailViewModel!
    private var disposeBag = DisposeBag()
    private let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
        setGesture()
        picker.delegate = self
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
                let url = URL(string: memo.imageURL)
                self.memoImageView.kf.setImage(with: url)
                self.memoTextView.text = memo.text
            }.disposed(by: disposeBag)

        viewModel.deleteButtonTapped.bind{ _ in
            self.askDeleteAlert()
                .bind(to: self.viewModel.memoDeleteAction)
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.cancelAfterMemoHasEdited.bind { _ in
            self.askCancelAfterEditAlert()
                .bind(to: self.viewModel.memoCancelAction)
            .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.saveButtonTapped.bind { _ in
            self.askSaveAfterEditAlert()
                .bind(to: self.viewModel.memoSaveAction)
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.isMemoEdited
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer()
        memoImageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind { recognizer in
            self.openLibrary()
        }.disposed(by: disposeBag)
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

extension MemoDetailViewController {
    private func askDeleteAlert() -> Observable<AlertType> {
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
    
    private func askSaveAfterEditAlert() -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: "수정 확인", message: "메모를 수정하시겠습니까?", preferredStyle: .alert)
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
    
    private func askCancelAfterEditAlert() -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: "취소 확인", message: "메모 수정을 취소하시겠습니까?", preferredStyle: .alert)
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
