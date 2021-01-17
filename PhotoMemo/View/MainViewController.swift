//
//  ViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/16.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    var data = RealmManager.shared.loadData(Memo.self)
    @IBOutlet var memoCollectionView: UICollectionView!
    
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
    
    private func setupUI() {
        memoCollectionView.delegate = self
        memoCollectionView.dataSource = self
        
        let nib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.register(nib, forCellWithReuseIdentifier: "memoCell")
    }
    
    private func configureFlowLayout() {
        guard let layout = memoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize.width = memoCollectionView.frame.width / 3 - 10
        memoCollectionView.setCollectionViewLayout(layout, animated: false)
        memoCollectionView.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoCell", for: indexPath) as! MemoCollectionViewCell
        cell.text?.text = data[indexPath.row].id.description

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MemoDetailViewController") as? MemoDetailViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
