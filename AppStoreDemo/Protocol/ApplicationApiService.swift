//
//  ApplicationApiService.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 9/7/2021.
//

import Foundation

protocol ApplicationApiService {
    // The api is kind of special so we will need to fetch the rating of each app seperately.
    
    /*
     Fetch Top Free apps with given limit. Return an array of AppData.
     */
    func fetchTopFreeApps(limit: Int, completionHandler: @escaping(_ results: [AppData]?, _ error: Error?) -> ())
    
    /*
     Fetch Top Grossing apps with given limit. Return an array of AppData.
     */
    func fetchTopGrossingApps(limit: Int, completionHandler: @escaping(_ results: [AppData]?, _ error: Error?) -> ())
    
    /*
     Fetch app icon from url. Return image Data.
     */
    func downloadImage(from url: URL, completionHandler: @escaping (_ imageData: Data?, _ error: Error?) -> ())
    
    /*
     Fetch rating for appId. Return LookupResult.
     */
    func fetchAppRating(for appId: String, completionHandler: @escaping (_ result: LookupResult?, _ error: Error?) -> ())
    
}
