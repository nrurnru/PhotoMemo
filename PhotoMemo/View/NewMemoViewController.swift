//
//  NewMemoViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit

class NewMemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "새 메모"
        
        let memo = Memo()
        memo.text = String(Int.random(in: 0...9))
        RealmManager.shared.saveData(data: memo)
    }
}
