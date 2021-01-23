//
//  NewMemoViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import CryptoSwift

class NewMemoViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "새 메모"
        
    }
    
    func setup() {
        memoTextView.delegate = self
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let memo = Memo()
        
        memo.id = Date().description.sha256()
        memo.text = memoTextView.text
        
        RealmManager.shared.saveData(data: memo)
        navigationController?.popViewController(animated: true)
    }
}
