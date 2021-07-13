//
//  AppRecord.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 11/7/2021.
//

import Foundation
import CoreData

protocol AppRecord {
    var appId: String? { get set }
    var title: String? { get set }
    var author: String? { get set }
    var category: String? { get set }
    var imgUrl: String? { get set }
    var ranking: Int32 { get set }
    var summary: String? { get set }
    var lastUpdate: Date? { get set }
}
