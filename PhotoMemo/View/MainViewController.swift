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
    @IBOutlet var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteBannerLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
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
        
        deleteMemoBarButton.rx.tap
            .bind(to: viewModel.deleteButtonTapped)
            .disposed(by: disposeBag)
        
        syncBarButton.rx.tap
            .bind(to: viewModel.syncButtonTapped)
            .disposed(by: disposeBag)
        
        logoutBarButton.rx.tap
            .bind(to: viewModel.logoutButtonTapped)
            .disposed(by: disposeBag)
        
        searchBarButton.rx.tap
            .bind(to: viewModel.searchButtonTapped)
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.memoDeleteMode
            .bind(to: self.memoCollectionView.rx.isEditing)
            .disposed(by: disposeBag)
        
        viewModel.askDeleteMemoAlert.bind { _ in
            self.alertAskObserver(title: "삭제 확인", message: "선택된 메모를 삭제하시겠습니까?")
                .bind(to: self.viewModel.deleteAction)
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        viewModel.memoDeleteMode
            .subscribe(on: MainScheduler.instance)
            .bind { isBannerShowing in
            if isBannerShowing {
                self.updateConstraintWithAnimation(of: self.deleteBannerLabelHeight, to: 30)
            } else {
                self.updateConstraintWithAnimation(of: self.deleteBannerLabelHeight, to: 0)
            }
        }.disposed(by: disposeBag)
        
        viewModel.isSearchBarShowing
            .subscribe(on: MainScheduler.instance)
            .bind { isSearchBarShowing in
                if isSearchBarShowing {
                    self.updateConstraintWithAnimation(of: self.searchBarHeight, to: 56)
                } else {
                    self.updateConstraintWithAnimation(of: self.searchBarHeight, to: 0)
                }
            }.disposed(by: disposeBag)
        
        viewModel.logoutButtonTapped.bind { _ in
            self.alertAskObserver(title: "로그아웃", message: "로그아웃 하시겠습니까?")
                .bind(to: self.viewModel.logoutAction)
                .disposed(by: self.disposeBag)
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
    
    private func updateConstraintWithAnimation(of constraint: NSLayoutConstraint, to size: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            constraint.constant = size
            self.view.layoutIfNeeded()
        }
    }
}
