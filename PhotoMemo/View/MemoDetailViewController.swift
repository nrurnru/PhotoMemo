//
//  MemoDetailViewController.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit

class MemoDetailViewController: UIViewController {

    @IBOutlet var memoTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func setUp() {
        memoTextView.delegate = self
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.backgroundColor = .white
        
    }

}

extension MemoDetailViewController: UITextViewDelegate {
    //
}
