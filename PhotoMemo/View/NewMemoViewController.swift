//
//  NewMemoViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RealmSwift

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
        let lastNumber: Int? = realm.objects(Memo.self).max(ofProperty: "number")

        memo.number = (lastNumber ?? 0) + 1
        memo.text = memoTextView.text
        
        RealmManager.shared.saveData(data: memo)
        NetworkManager.shared.post(memo: memo)
        navigationController?.popViewController(animated: true)
    }
}
