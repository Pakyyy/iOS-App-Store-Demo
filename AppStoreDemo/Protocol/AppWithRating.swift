//
//  AppWithRating.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 13/7/2021.
//

import Foundation

protocol AppWithRating {
    var rating: Double { get set }
    var ratingCount: Int32 { get set }
}
