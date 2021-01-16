//
//  ViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/16.
//

import UIKit

class MainViewController: UIViewController {
    var data = [1,2,3,4,5]
    @IBOutlet var memoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "메모 목록"
    }
    func setupUI() {
        memoCollectionView.delegate = self
        memoCollectionView.dataSource = self
        
        let nib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.register(nib, forCellWithReuseIdentifier: "memoCell")
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoCell", for: indexPath) as! MemoCollectionViewCell
        cell.text?.text = indexPath.row.description

        return cell
    }
}
