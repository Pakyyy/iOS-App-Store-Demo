//
//  CoreDataManager.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import Foundation
import CoreData

class CoreDataManager: CoreDataService {
    
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AppStoreDemo")
    
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // mainContext will only handle UI related task
    // and create backgroundContext to handle all other insert / update / delete
    lazy private var mainContext: NSManagedObjectContext = {
        let viewContext = Self.persistentContainer.viewContext
        // We added unique constraint to the App's ranking
        // if new Apps data with same ranking is inserted, the new one will replace the old one
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // automatically merges changes when backgroundContext is updated
        viewContext.automaticallyMergesChangesFromParent = true
        
        return viewContext
    }()
    
    lazy private var savingContext: NSManagedObjectContext = {
        let backgroundContext = Self.persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }()
    
    private func saveMainContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch let error as NSError {
                fatalError("saveMainContext error \(error), \(error.userInfo)")
            }
        }
    }
    
    private func saveSavingContext() {
        if savingContext.hasChanges {
            do {
                try savingContext.save()
            } catch let error as NSError {
                fatalError("savingContext error \(error), \(error.userInfo)")
            }
        }
    }
        
}

// MARK: Top Grossing Application
extension CoreDataManager {
    
    func batchInsertGrossingApps(from appDatas: [AppData]) {
        savingContext.performAndWait {
            for (index, appData) in appDatas.enumerated() {
                let grossingApp = GrossingApplication(context: savingContext)
                grossingApp.ranking = Int32(index)
                grossingApp.lastUpdate = Date()
                
                grossingApp.appId = appData.appId
                grossingApp.author = appData.author
                grossingApp.title = appData.title
                grossingApp.imgUrl = appData.imgUrl
                grossingApp.category = appData.category
                grossingApp.summary = appData.summary
            }
            
            saveSavingContext()
        }
    }
    
    func grossingAppsFetchedResultsController(ascending: Bool, fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<GrossingApplication> {
        let request = GrossingApplication.fetchRequest() as NSFetchRequest<GrossingApplication>
        request.sortDescriptors = [NSSortDescriptor(key: Schema.GrossingApplication.ranking.rawValue, ascending: ascending)]
        
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch let error as NSError {
            fatalError("[CoreDataManager] grossingAppsFetchedResultsController fetch error: \(error), \(error.userInfo)")
        }
        
        return controller
    }
    
    func updateTopGrossingAppsFetchedResultsController(_ controller: NSFetchedResultsController<GrossingApplication>, searchString: String, completionHandler: () -> ()) {
        // search for "app name, category, author or summary contains the keyword"
        controller.fetchRequest.predicate = searchString.count > 0 ? NSPredicate(format: "title contains[c] %@ OR author contains[c] %@ OR category contains[c] %@ OR summary contains[c] %@", searchString, searchString, searchString, searchString) : nil
        
        do {
            try controller.performFetch()
            // performFetch again won't trigger NSFetchedResultsControllerDelegate didChangeContent
            completionHandler()
        } catch let error as NSError {
            fatalError("[CoreDataManager] updateTopGrossingAppsFetchedResultsController fetch error: \(error), \(error.userInfo)")
        }
    }
    
}

// MARK: Top Free Application
extension CoreDataManager {
    
    // We would expect the batch size is relative small in this demo, so we do not concern about memory issue, and only save after all AppData is created (just let them stay on memory)
    func batchInsertFreeApps(from appDatas: [AppData]) {
        savingContext.performAndWait {
            for (index, appData) in appDatas.enumerated() {
                let freeApp = FreeApplication(context: savingContext)
                freeApp.ranking = Int32(index)
                // not adding lastUpdate until rating & ratingCount is added
                // freeApp.lastUpdate = Date()
                
                freeApp.appId = appData.appId
                freeApp.author = appData.author
                freeApp.title = appData.title
                freeApp.imgUrl = appData.imgUrl
                freeApp.category = appData.category
                freeApp.summary = appData.summary
            }
            
            saveSavingContext()
        }
    }
    
    func insertAppRating(appId: String, rating: Double, ratingCount: Int) {
        savingContext.performAndWait {
            let request = FreeApplication.fetchRequest() as NSFetchRequest<FreeApplication>
            let predicate = NSPredicate(format: "appId == %@", appId)
            request.predicate = predicate
            do {
                let freeApps = try savingContext.fetch(request)
                guard let freeApp = freeApps.first else { return }
                
                freeApp.rating = rating
                // Int32 has a upper bound of 2.1 billion, if ratingCount is > 2.1billion the app will crash, but that's highly not likely gonna happan for a reasonable response data
                freeApp.ratingCount = Int32(ratingCount)
                freeApp.lastUpdate = Date()
            } catch let error as NSError {
                print("insertAppRating for appId \(appId) failed. \(error), \(error.userInfo)")
                return
            }
            
            saveSavingContext()
        }
    }
    
    func freeAppsFetchedResultsController(ascending: Bool, fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<FreeApplication> {
        let request = FreeApplication.fetchRequest() as NSFetchRequest<FreeApplication>
        request.sortDescriptors = [NSSortDescriptor(key: Schema.FreeApplication.ranking.rawValue, ascending: ascending)]
        request.fetchBatchSize = 10
        
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch let error as NSError {
            fatalError("[CoreDataManager] freeAppsFetchedResultsController fetch error: \(error), \(error.userInfo)")
        }
        
        return controller
    }
    
    func updateFreeAppsFetchedResultsController(_ controller: NSFetchedResultsController<FreeApplication>, searchString: String, completionHandler: () -> ()) {
        // search for "app name, category, author or summary contains the keyword"
        controller.fetchRequest.predicate = searchString.count > 0 ? NSPredicate(format: "title contains[c] %@ OR author contains[c] %@ OR category contains[c] %@ OR summary contains[c] %@", searchString, searchString, searchString, searchString) : nil
        
        do {
            try controller.performFetch()
            // performFetch again won't trigger NSFetchedResultsControllerDelegate didChangeContent
            completionHandler()
        } catch let error as NSError {
            fatalError("[CoreDataManager] updateFreeAppsFetchedResultsController fetch error: \(error), \(error.userInfo)")
        }
    }
    
}

// MARK: App Icon Cache
extension CoreDataManager {
    
    func insertAppIcon(imageUrl: String, imageData: Data) {
        savingContext.performAndWait {
            let appIcon = AppIcon(context: savingContext)
            appIcon.imgData = imageData
            appIcon.imgUrl = imageUrl
            appIcon.lastUpdate = Date()
        }
        
        saveSavingContext()
    }
    
    func getAppIcon(imageUrl: String) -> Data? {
        let request = AppIcon.fetchRequest() as NSFetchRequest<AppIcon>
        let predicate = NSPredicate(format: "imgUrl == %@", imageUrl)
        request.predicate = predicate
        do {
            let appIconData = try mainContext.fetch(request)
            return appIconData.first?.imgData
        } catch let error as NSError {
            print("getAppIcon for imageUrl \(imageUrl) error. \(error), \(error.userInfo)")
            return nil
        }
    }
    
}
