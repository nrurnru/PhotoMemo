//
//  MemoDetailViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RealmSwift

class MemoDetailViewController: UIViewController {

    @IBOutlet var memoTextView: UITextView!
    var memo: Memo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "메모 보기"
    }
    
    private func setUp() {
        memoTextView.delegate = self
        memoTextView.text = memo?.text
    }
    
    private func setupUI() {

    }

    @IBAction func saveAction(_ sender: Any) {
        guard let memo = self.memo else { return }
        guard let text = memoTextView.text else { return }
        RealmManager.shared.updateMemo(memo: memo, text: text)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        guard let memo = self.memo else { return }
        var deletedMemoIDs = UserDefaults.standard.array(forKey: "deletedMemoIDs") as! [String]
        deletedMemoIDs.append(memo.id)
        UserDefaults.standard.set(deletedMemoIDs, forKey: "deletedMemoIDs")
        RealmManager.shared.deleteData(data: memo)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MemoDetailViewController: UITextViewDelegate {
    //
}
