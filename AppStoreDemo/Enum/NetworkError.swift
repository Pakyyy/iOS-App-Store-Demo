//
//  NetworkError.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 9/7/2021.
//

import Foundation

enum NetworkError: Error {
    case dataNotAvailable
    case invalidUrl
    case serverResponseError
}
