//
//  AppIcon+CoreDataProperties.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 10/7/2021.
//
//

import Foundation
import CoreData


extension AppIcon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppIcon> {
        return NSFetchRequest<AppIcon>(entityName: "AppIcon")
    }

    @NSManaged public var imgData: Data?
    @NSManaged public var imgUrl: String?
    @NSManaged public var lastUpdate: Date?

}

extension AppIcon : Identifiable {

}
