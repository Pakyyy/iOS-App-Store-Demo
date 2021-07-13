//
//  MainListViewModel.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import Foundation
import CoreData

// Loading indicator will only be shown when fetching the whole list (top grosing apps & top free apps)
// fetching icon & fetching rating of each apps will not show indicator and block the main thread
// therefore poor network have minimum effect to the UI

class MainListViewModel: NSObject {

    private var dataManager: CoreDataService
    // any mock object that conform to ApplicationApiService protocol can be injected for testing
    private var networkManager: ApplicationApiService
    
    // Here we just loadingGroup to chain all fetch request
    private let loadingGroup = DispatchGroup()
    
    // use Dynamic to ensure unidirection of data flow
    var isLoading = Dynamic<Bool>(false)

    // NSFetchedResultsController for grossingApps CollectionView
    // Indeed UICollectionView not quite fit to NSFetchedResultsController delegate, we will need to create a OperationQueue to use preformBatchUpdates of UICollection to achieve the same behaviours of beginUpdates/endUpdate of UITableView
    // But here we expect the collectionView is not likely to update frequently, so we just reloadData()
    var grossingAppDidSet: (() -> ())?
    lazy var grossingAppsFetchedResultsController: NSFetchedResultsController<GrossingApplication> = {
        return dataManager.grossingAppsFetchedResultsController(ascending: true, fetchedResultsControllerDelegate: self)
    }()
    
    // NSFetchedResultsController for topFreeApp TableView
    var freeAppWillSet: (() -> ())?
    var freeAppDidSet: (() -> ())?
    var freeAppSectionDidChange: ((_ type: NSFetchedResultsChangeType, _ section: Int) -> ())?
    var freeAppDidChange: ((_ type: NSFetchedResultsChangeType, _ indexPaths: IndexPath?, _ newIndexPath: IndexPath?) -> ())?
    var freeAppDidSearch: (() -> ())?
    lazy var freeAppsFetchedResultsController: NSFetchedResultsController<FreeApplication> = {
        return dataManager.freeAppsFetchedResultsController(ascending: true, fetchedResultsControllerDelegate: self)
    }()
    
    init(dataManager: CoreDataService, networkManager: ApplicationApiService) {
        self.dataManager = dataManager
        self.networkManager = networkManager
    }
    
    func searchFreeApp(name: String) {
        dataManager.updateFreeAppsFetchedResultsController(freeAppsFetchedResultsController, searchString: name) {
            freeAppDidSearch?()
        }
        
        dataManager.updateTopGrossingAppsFetchedResultsController(grossingAppsFetchedResultsController, searchString: name) {
            grossingAppDidSet?()
        }
    }
    
    func fetchAllApplication() {
        fetchTopGrossingApplication()
        fetchApplicationList()
        
        loadingGroup.notify(queue: DispatchQueue.main) {
            self.isLoading.value = false
        }
    }
    
    // Assist function
    private func sameDayOrNil(for date: Date?) -> Bool {
        guard let date = date else { return true }
        
        return !Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    func loadRating(for app: AppRecord & AppWithRating) {
        // return if the rating is updated in the same day
        guard app.rating == 0.0,
              app.ratingCount == 0,
              sameDayOrNil(for: app.lastUpdate),
              let appId = app.appId else { return }

        networkManager.fetchAppRating(for: appId) { lookupResult, error in
            guard error == nil,
                  let lookupResult = lookupResult else { return }
            self.dataManager.insertAppRating(appId: appId, rating: lookupResult.averageUserRatingForCurrentVersion, ratingCount: lookupResult.userRatingCountForCurrentVersion)
        }
    }
    
    func loadImage(for app: AppRecord, completionHandler: @escaping (_ imageData: Data?) -> ()) {
        guard let urlString = app.imgUrl else {
            completionHandler(nil)
            return
        }
        // get image data from Core Data
        // if no match, fetch from api
        // save the result to core data for future use
        if let cachedAppIcon = dataManager.getAppIcon(imageUrl: urlString) {
            DispatchQueue.main.async {
                completionHandler(cachedAppIcon)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completionHandler(nil)
            }
            return
        }
        
        // ever the row is getting out of screen, we still download the image for future use, no need to cancel the downloading
        networkManager.downloadImage(from: url) { [weak self] data, error in
            if let _ = error {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            guard let imageData = data else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(imageData)
            }
            self?.dataManager.insertAppIcon(imageUrl: urlString, imageData: imageData)
        }
    }
    
    // fetch top free apps and insert into coredata
    private func fetchApplicationList() {
        loadingGroup.enter()
        networkManager.fetchTopFreeApps(limit: 100) { freeAppList, error in
            guard error == nil,
                  let freeAppList = freeAppList,
                  freeAppList.count > 0 else { return }
            
            self.dataManager.batchInsertFreeApps(from: freeAppList)
            self.loadingGroup.leave()
        }
    }
    
    // fetch top grossing apps and insert into coredata
    private func fetchTopGrossingApplication() {
        loadingGroup.enter()
        networkManager.fetchTopGrossingApps(limit: 10) { grossingAppList, error in
            guard error == nil,
                  let grossingAppList = grossingAppList,
                  grossingAppList.count > 0 else { return }
            
            self.dataManager.batchInsertGrossingApps(from: grossingAppList)
            self.loadingGroup.leave()
        }
    }
    
}

// Placing the NSFetchedReultsControllerDelegate in ViewModel to ensure unidirectional of data flow
// CoreData Model > ViewModel > ViewController
// and ensure all viewController care about is UI stuff
extension MainListViewModel: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if controller == freeAppsFetchedResultsController {
            freeAppSectionDidChange?(type, sectionIndex)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == freeAppsFetchedResultsController {
            freeAppDidChange?(type, indexPath, newIndexPath)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == freeAppsFetchedResultsController {
            freeAppWillSet?()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == freeAppsFetchedResultsController {
            freeAppDidSet?()
        } else {
            grossingAppDidSet?()
        }
    }
    
}
