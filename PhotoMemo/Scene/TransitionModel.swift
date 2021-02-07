//
//  TransitionModel.swift
//  PhotoMemo
//
//  Created by 최광현 on 2021/02/07.
//

import Foundation

enum TransitionStyle {
    case root
    case push
    case modal
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
