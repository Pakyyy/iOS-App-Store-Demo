//
//  GrossingApplication+CoreDataProperties.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 11/7/2021.
//
//

import Foundation
import CoreData


extension GrossingApplication {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GrossingApplication> {
        return NSFetchRequest<GrossingApplication>(entityName: "GrossingApplication")
    }

    @NSManaged public var appId: String?
    @NSManaged public var author: String?
    @NSManaged public var category: String?
    @NSManaged public var imgUrl: String?
    @NSManaged public var lastUpdate: Date?
    @NSManaged public var ranking: Int32
    @NSManaged public var summary: String?
    @NSManaged public var title: String?

}

extension GrossingApplication : Identifiable {

}

extension GrossingApplication: AppRecord {
    
}
