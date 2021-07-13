//
//  Constants.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import Foundation

struct Constants {
    
    // REMARK: We could create an URL object and dynamically add those path/query limit/parameters, but for demo purpose I will just use these hard code url.
//    static let appListingUrl = "https://itunes.apple.com/hk/rss/topfreeapplications/limit=100/json"
    static let appListingUrl = "https://itunes.apple.com/hk/rss/topfreeapplications/limit=10/json"
    static let appListingLookupUrl = "https://itunes.apple.com/hk/lookup" // id=[app_id]
    static let appRecommendationUrl = "https://itunes.apple.com/hk/rss/topgrossingapplications/limit=10/json"
    
}
