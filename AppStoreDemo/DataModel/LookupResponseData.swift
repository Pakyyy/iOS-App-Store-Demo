//
//  LookupResponseData.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 10/7/2021.
//

import Foundation

struct LookupResponseData: Codable {
    let result: LookupResult
    
    enum ResultsKey: CodingKey { case results }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResultsKey.self)
        let results = try container.decode([LookupResult].self, forKey: .results)
        if let firstResult = results.first {
            self.result = firstResult
        } else {
            throw NetworkError.dataNotAvailable
        }
    }
}

struct LookupResult: Codable {
    let averageUserRatingForCurrentVersion: Double
    let userRatingCountForCurrentVersion: Int
}
