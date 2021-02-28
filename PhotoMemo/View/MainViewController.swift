//
//  ViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/16.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftKeychainWrapper
import RealmSwift

class MainViewController: UIViewController {
    var selectedItem: [Memo] = []
    var viewModel: MainViewModel!
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet var memoCollectionView: UICollectionView!
    @IBOutlet var newMemoBarButton: UIBarButtonItem!
    @IBOutlet var deleteMemoBarButton: UIBarButtonItem!
    @IBOutlet var syncBarButton: UIBarButtonItem!
    @IBOutlet var logoutBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBannerLabelHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindCollectionView()
        
        setupUI()
        configureFlowLayout()
        
        bindInput()
        bindOutput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoCollectionView.allowsSelection = true
        viewModel.startSync()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        memoCollectionView.allowsSelection = false
    }
    
    private func bindInput() {
        newMemoBarButton.rx.tap
            .bind(to: viewModel.newMemoButtonTapped)
            .disposed(by: disposeBag)

        deleteMemoBarButton.rx.tap.bind(onNext: { _ in
            self.memoCollectionView.isEditing.toggle()
            self.updateSizeOfDeleteBanner(30)
            self.viewModel.isEditmode.accept(self.memoCollectionView.isEditing)
        }).disposed(by: disposeBag)

        syncBarButton.rx.tap
            .bind(to: viewModel.syncButtonTapped)
            .disposed(by: disposeBag)
        
        logoutBarButton.rx.tap
            .bind(to: viewModel.logoutButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.deleteCompleted
            .bind { result in
                if result {
                    self.updateSizeOfDeleteBanner(0)
                }
            }.disposed(by: disposeBag)
        
        viewModel.syncCompleted
            .bind { result in
                if result {
                    //sync
                }
            }.disposed(by: disposeBag)
        
        viewModel.logoutButtonTapped.bind { _ in
            self.logoutAlert().bind(to: self.viewModel.logoutAction).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        viewModel.data
            .bind(to: memoCollectionView.rx.items(cellIdentifier: "memoCell", cellType: MemoCollectionViewCell.self)) { index, memo, cell in
                cell.text?.text = memo.text
                cell.memoImageView.kf.setImage(with: URL(string: memo.imageURL))
                cell.layer.borderWidth = 1
                cell.layer.borderColor = self.view.backgroundColor?.cgColor
            }.disposed(by: disposeBag)
        
        
        memoCollectionView.rx.modelSelected(Memo.self).bind { memo in
            if self.memoCollectionView.isEditing {
                self.viewModel.selectedMemoForDelete.accept(memo)
            } else {
                self.viewModel.selectMemoForDetail.accept(memo)
            }
        }.disposed(by: disposeBag)
        
        memoCollectionView.rx.modelDeselected(Memo.self).bind { memo in
            if self.memoCollectionView.isEditing {
                self.viewModel.deselectedMemoForDelete.accept(memo)
            }
        }.disposed(by: disposeBag)
    }
    
    private func setupUI() {
        memoCollectionView.allowsMultipleSelectionDuringEditing = true
        
        let nib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.register(nib, forCellWithReuseIdentifier: "memoCell")
    }
    
    private func configureFlowLayout() {
        guard let layout = memoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let itemSize = view.frame.width / 3
        layout.itemSize.width = itemSize
        layout.itemSize.height = itemSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        memoCollectionView.setCollectionViewLayout(layout, animated: false)
        memoCollectionView.reloadData()
    }
    
    private func updateSizeOfDeleteBanner(_ size: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.deleteBannerLabelHeight.constant = size
            self.view.layoutIfNeeded()
        }
    }
}

extension MainViewController {
    private func logoutAlert() -> Observable<AlertType> {
        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
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
