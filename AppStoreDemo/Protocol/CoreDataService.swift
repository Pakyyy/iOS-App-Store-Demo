//
//  CoreDataService.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 9/7/2021.
//

import Foundation
import CoreData

protocol CoreDataService {
    
    // For Top Grossing Application
    func batchInsertGrossingApps(from appDatas: [AppData])
    func grossingAppsFetchedResultsController(ascending: Bool, fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<GrossingApplication>
    func updateTopGrossingAppsFetchedResultsController(_ controller: NSFetchedResultsController<GrossingApplication>, searchString: String, completionHandler: () -> ())
    
    // For Top Free Application
    func batchInsertFreeApps(from appDatas: [AppData])
    func insertAppRating(appId: String, rating: Double, ratingCount: Int)
    func freeAppsFetchedResultsController(ascending: Bool, fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<FreeApplication>
    func updateFreeAppsFetchedResultsController(_ controller: NSFetchedResultsController<FreeApplication>, searchString: String, completionHandler: () -> ())
    
    // For caching App Icon
    func insertAppIcon(imageUrl: String, imageData: Data)
    func getAppIcon(imageUrl: String) -> Data?
    
}
