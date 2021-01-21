//
//  NewMemoViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RealmSwift
import CryptoSwift

class NewMemoViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var memoTextView: UITextView!
    let realm = try! Realm()
    
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
        
        memo.id = Date().description.sha512()
        memo.number = ""
        memo.text = memoTextView.text
        
        RealmManager.shared.saveData(data: memo)
        navigationController?.popViewController(animated: true)
    }
}
