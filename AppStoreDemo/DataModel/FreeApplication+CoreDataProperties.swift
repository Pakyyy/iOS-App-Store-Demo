//
//  FreeApplication+CoreDataProperties.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 11/7/2021.
//
//

import Foundation
import CoreData


extension FreeApplication {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FreeApplication> {
        return NSFetchRequest<FreeApplication>(entityName: "FreeApplication")
    }

    @NSManaged public var appId: String?
    @NSManaged public var author: String?
    @NSManaged public var category: String?
    @NSManaged public var imgUrl: String?
    @NSManaged public var lastUpdate: Date?
    @NSManaged public var ranking: Int32
    @NSManaged public var rating: Double
    @NSManaged public var ratingCount: Int32
    @NSManaged public var summary: String?
    @NSManaged public var title: String?

}

extension FreeApplication : Identifiable {

}

extension FreeApplication: AppRecord {
    
}

extension FreeApplication: AppWithRating {
    
}
