//
//  Scene.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/07.
//

import UIKit
import RxCocoa

enum Scene {
    case login(LoginViewModel)
    case memoList(MainViewModel)
    case detail(MemoDetailViewModel)
    case newMemo(NewMemoViewModel)
}

extension Scene {
    func instantiate(from Storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: Storyboard, bundle: nil)
        
        switch self {
        case .login(let viewModel):
            guard let nav = storyboard.instantiateViewController(identifier: "RootVC") as? UINavigationController else {
                print("it's not UINavigationController")
                return UIViewController()
            }
            guard let loginVC = nav.viewControllers.first as? LoginViewController else {
                print("it's not LoginViewController")
                return UIViewController()
            }
            loginVC.viewModel = viewModel
            return nav
            
        case .memoList(let viewModel):
            guard let memoListVC = storyboard.instantiateViewController(identifier: "MemoListVC") as? MainViewController else {
                print("it's not MainViewController")
                return UIViewController()
            }
            memoListVC.viewModel = viewModel
            return memoListVC
            
        case .detail(let viewModel):
            guard let detailVC = storyboard.instantiateViewController(identifier: "MemoDetailVC") as? MemoDetailViewController else {
                print("it's not DetailViewController")
                return UIViewController()
            }
            detailVC.viewModel = viewModel
            return detailVC
            
        case .newMemo(let viewModel):
            guard let newMemoVC = storyboard.instantiateViewController(identifier: "NewMemoVC") as? NewMemoViewController else {
                print("it's not NewMemoViewController")
                return UIViewController()
            }
            newMemoVC.viewModel = viewModel
            return newMemoVC
        }
        
    }
}
