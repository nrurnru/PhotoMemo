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
        memoCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncData()
    }
    
    private func bindInput() {
        newMemoBarButton.rx.tap
            .bind(to: viewModel.newMemoButtonTapped)
            .disposed(by: disposeBag)
//
//        deleteMemoBarButton.rx.tap
//            .bind(to: viewModel.deleteMemoButtonTapped)
//            .disposed(by: disposeBag)
//
//        syncBarButton.rx.tap
//            .bind(to: viewModel.syncButtonTapped)
//            .disposed(by: disposeBag)
        
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
                cell.layer.borderWidth = 1
                cell.layer.borderColor = self.view.backgroundColor?.cgColor
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
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        switch memoCollectionView.isEditing {
        case true: //수정끝
            //TODO: 확인 알림 필요
            var deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") as! [String]
            deletedMemoIDs.append(contentsOf: selectedItem.map { $0.id })
            UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
            RealmManager.shared.deleteDataList(dataList: selectedItem)
            selectedItem.removeAll()
            
            newMemoBarButton.isEnabled = true
            deleteMemoBarButton.tintColor = .systemBlue
            memoCollectionView.isEditing = false
            memoCollectionView.reloadData()
            
        case false: //수정시작
            memoCollectionView.isEditing = true
            deleteMemoBarButton.tintColor = .systemRed
            newMemoBarButton.isEnabled = false
        }
    }
    @IBAction func syncAction(_ sender: UIBarButtonItem) {
        syncBarButton.tintColor = .red
        syncData()
    }
}

//extension MainViewController: {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch memoCollectionView.isEditing {
//        case true:
//            let memo = data[indexPath.row]
//            self.selectedItem.append(memo)
//        case false:
//            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MemoDetailViewController") as? MemoDetailViewController else { return }
//            vc.viewModel = MemoDetailViewModel(memo: data[indexPath.row])
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        guard memoCollectionView.isEditing == true else { return }
//        let memo = data[indexPath.row]
//        guard let index = selectedItem.firstIndex(of: memo) else { return }
//        selectedItem.remove(at: index)
//    }
//}

extension MainViewController {
    func syncData() {
        let updatedMemos = RealmManager.shared.fetchUpdatedMemo().map { MemoAdapter(memo: $0) }
        let deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") ?? []
        guard let d = deletedMemoIDs as? [String] else { return }
        
        
        let syncData = SyncData(updatedMemos: updatedMemos, deletedMemoIDs: d)
        
        NetworkManager.shared.upSync(syncData: syncData) { [weak self] in
            NetworkManager.shared.downSync { syncData in
                syncData.updatedMemos.forEach { updatedMemo in
                    RealmManager.shared.saveData(data: updatedMemo.toMemo())
                }
                RealmManager.shared.deleteDataWithIDs(Memo.self, deletedIDs: syncData.deletedMemoIDs)
                UserDefaults.standard.set([], forKey: "deletedMemoIDs")
                UserDefaults.standard.set(ISO8601DateFormatter().string(from: Date()), forKey: "lastSynced")
                self?.memoCollectionView.reloadData()
                DispatchQueue.main.async {
                    self?.syncBarButton.tintColor = .systemBlue
                }
            }
        }
    }
}
