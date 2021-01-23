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
    @IBOutlet var syncBarButton: UIBarButtonItem!
    
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
