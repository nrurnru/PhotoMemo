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
    let viewModel = MainViewModel()
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet var memoCollectionView: UICollectionView!
    @IBOutlet var newMemoBarButton: UIBarButtonItem!
    @IBOutlet var deleteMemoBarButton: UIBarButtonItem!
    @IBOutlet var syncBarButton: UIBarButtonItem!
    @IBOutlet var logoutBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.hidesBackButton = true
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
        viewModel.logoutSuccessed
            .bind { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    print("logout failed..")
                }
            }.disposed(by: disposeBag)
        
        viewModel.newMemo
            .bind { _ in
                self.performSegue(withIdentifier: "newMemo", sender: nil)
            }.disposed(by: disposeBag)
        
        viewModel.deleteCompleted
            .bind { result in
                if result {
                    //delete
                }
            }.disposed(by: disposeBag)
        
        viewModel.syncCompleted
            .bind { result in
                if result {
                    //sync
                }
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
                self.performSegue(withIdentifier: "memoDetail", sender: memo)
            }
        }.disposed(by: disposeBag)
        
        memoCollectionView.rx.modelDeselected(Memo.self).bind { memo in
            if self.memoCollectionView.isEditing {
                self.viewModel.deselectedMemoForDelete.accept(memo)
            }
        }.disposed(by: disposeBag)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? MemoDetailViewController, let memo = sender as? Memo else { return }
        destination.viewModel = MemoDetailViewModel(memo: memo)
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
}
