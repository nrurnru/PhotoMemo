//
//  NetworkError.swift
//  PhotoMemo
//
//  Created by GH Choi on 2021/03/03.
//

import Foundation

enum NetworkError: Error {
    case unauthorized
    case parsingError
    case serverError
    case idAlreadyExists
}
