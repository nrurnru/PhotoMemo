//
//  MemoCollectionViewCell.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/01/17.
//

import UIKit
import RxCocoa
import RxSwift

class MemoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var text: UILabel!
    @IBOutlet var memoImageView: UIImageView!
    @IBOutlet var checkMarkImageView: UIImageView!
    
    private var disposeBag = DisposeBag()
    private let isChecked = PublishRelay<Bool>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindCheckView()
    }
    
    private func bindCheckView() {
        isChecked.bind { check in
            self.checkMarkImageView.isHidden = !check
        }.disposed(by: disposeBag)
    }
    
    override var isSelected: Bool {
        didSet {
            isChecked.accept(isSelected)
        }
    }
}
