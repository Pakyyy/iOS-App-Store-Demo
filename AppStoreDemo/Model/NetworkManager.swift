//
//  NetworkManager.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import Foundation

class NetworkManager: ApplicationApiService {
    
    private let urlSession = URLSession.shared
    
    func fetchTopFreeApps(limit: Int, completionHandler: @escaping(_ results: [AppData]?, _ error: Error?) -> ()) {
        guard limit > 0 else {
            completionHandler(nil, NetworkError.invalidUrl)
            return
        }
        
        // Using hardcode string for demo
        let topFreeApiUrlString = "https://itunes.apple.com/hk/rss/topfreeapplications/limit=\(limit)/json"
        
        guard let topFreeAppUrl = URL(string: topFreeApiUrlString) else {
            completionHandler(nil, NetworkError.invalidUrl)
            return }
        urlSession.dataTask(with: topFreeAppUrl) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, NetworkError.serverResponseError)
                return
            }
            
            guard let data = data else {
                let error = NetworkError.dataNotAvailable
                completionHandler(nil, error)
                return
            }
            
            do {
                let applicationListData = try JSONDecoder().decode(ApplicationListResponseData.self, from: data)
                // I doubt that if the api return the top free apps in ascending order, but thats beyond my concern
                completionHandler(applicationListData.entries, nil)
            } catch {
                completionHandler(nil, error)
            }
        }.resume()
    }
    
    func fetchTopGrossingApps(limit: Int, completionHandler: @escaping(_ results: [AppData]?, _ error: Error?) -> ()) {
        guard limit > 0 else {
            completionHandler(nil, NetworkError.invalidUrl)
            return
        }
        
        let topGrossingApiUrlString = "https://itunes.apple.com/hk/rss/topgrossingapplications/limit=\(limit)/json"
        
        guard let topGrossingAppUrl = URL(string: topGrossingApiUrlString) else {
            completionHandler(nil, NetworkError.invalidUrl)
            return }
        urlSession.dataTask(with: topGrossingAppUrl) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, NetworkError.serverResponseError)
                return
            }
            
            guard let data = data else {
                let error = NetworkError.dataNotAvailable
                completionHandler(nil, error)
                return
            }
            
            do {
                let applicationListData = try JSONDecoder().decode(ApplicationListResponseData.self, from: data)
                completionHandler(applicationListData.entries, nil)
            } catch {
                completionHandler(nil, error)
            }
        }.resume()
    }
    
    func downloadImage(from url: URL, completionHandler: @escaping (_ imageData: Data?, _ error: Error?) -> ()) {
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, NetworkError.serverResponseError)
                return
            }
            
            guard let data = data else {
                let error = NetworkError.dataNotAvailable
                completionHandler(nil, error)
                return
            }
            
            completionHandler(data, nil)
        }.resume()
    }
    
    func fetchAppRating(for appId: String, completionHandler: @escaping (_ result: LookupResult?, _ error: Error?) -> ()) {
        guard appId.count > 0 else {
            completionHandler(nil, NetworkError.invalidUrl)
            return
        }
        
        let lookupApiUrlString = "https://itunes.apple.com/hk/lookup?id=\(appId)"
        guard let lookupApiUrl = URL(string: lookupApiUrlString) else {
            completionHandler(nil, NetworkError.invalidUrl)
            return
        }
        urlSession.dataTask(with: lookupApiUrl) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, NetworkError.serverResponseError)
                return
            }
            
            guard let data = data else {
                completionHandler(nil, NetworkError.dataNotAvailable)
                return
            }
            
            do {
                let ratingResponseData = try JSONDecoder().decode(LookupResponseData.self, from: data)
                completionHandler(ratingResponseData.result, nil)
            } catch {
                completionHandler(nil, error)
            }
        }.resume()
    }
    
}
