//
//  ViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/16.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    var data = RealmManager.shared.loadData(Memo.self).sorted(byKeyPath: "createdAt", ascending: false)
    var selectedItem: [Memo] = []
    
    @IBOutlet var memoCollectionView: UICollectionView!
    @IBOutlet var newMemoBarButton: UIBarButtonItem!
    @IBOutlet var deleteMemoBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "메모 목록"
        memoCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncData()
    }
    
    private func setupUI() {
        memoCollectionView.delegate = self
        memoCollectionView.dataSource = self
        
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
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoCell", for: indexPath) as! MemoCollectionViewCell
        cell.text?.text = data[indexPath.row].text
        cell.layer.borderWidth = 1
        cell.layer.borderColor = view.backgroundColor?.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch memoCollectionView.isEditing {
        case true:
            let memo = data[indexPath.row]
            self.selectedItem.append(memo)
        case false:
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MemoDetailViewController") as? MemoDetailViewController else { return }
            vc.memo = data[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard memoCollectionView.isEditing == true else { return }
        let memo = data[indexPath.row]
        guard let index = selectedItem.firstIndex(of: memo) else { return }
        selectedItem.remove(at: index)
    }
}

extension MainViewController {
    func syncData() {
        let newMemos = [MemoAdapter(number: 1, text: "newMemo1")]
        let updatedMemos: [MemoAdapter] = []
        let deletedMemoIDs = ["1","2","3"]
        let syncData = SyncData(newMemos: newMemos, updatedMemos: updatedMemos, deletedMemoIDs: deletedMemoIDs)
        NetworkManager.shared.upSync(syncData: syncData)
        NetworkManager.shared.downSync()
    }
}
