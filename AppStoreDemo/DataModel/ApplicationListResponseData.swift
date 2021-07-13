//
//  ApplicationListResponseData.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 9/7/2021.
//

import Foundation

struct ApplicationListResponseData: Codable {
    let entries: [AppData]
    // We could add any other data we wanted in the future, depend on needs, for example:
    // let lastUpdate: String
    
    enum FeedKeys: CodingKey { case feed }
    enum EntryKeys: CodingKey { case entry }
    
    init(from decoder: Decoder) throws {
        let feed = try decoder.container(keyedBy: FeedKeys.self)
        let entries = try feed.nestedContainer(keyedBy: EntryKeys.self, forKey: .feed)
        self.entries = try entries.decode([AppData].self, forKey: .entry)
    }
}

// MARK: - SubLabel
struct SubLabel: Codable {
    let label: String
}

// AppData just grab the data we want from the JSON
struct AppData: Codable {
    let title: String
    let author: String
    let appId: String
    let imgUrl: String
    let summary: String
    let category: String
    
    enum LabelKeys: CodingKey { case label }
    enum AttributesKeys: CodingKey { case attributes }
    enum ImIdKeys: String, CodingKey { case imId = "im:id"}
    enum EntryKeys: String, CodingKey {
        case imName = "im:name"
        case imArtist = "im:artist"
        case imImage = "im:image"
        case summary
        case appId = "id"
        case category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EntryKeys.self)
        let titleContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .imName)
        self.title = try titleContainer.decode(String.self, forKey: .label)
        
        let artistContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .imArtist)
        self.author = try artistContainer.decode(String.self, forKey: .label)
        
        let appIdContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .appId)
        let appIdLabelContainer = try appIdContainer.nestedContainer(keyedBy: ImIdKeys.self, forKey: .attributes)
        self.appId = try appIdLabelContainer.decode(String.self, forKey: .imId)
        
        let imgUrls = try container.decode([SubLabel].self, forKey: .imImage)
        // grab the url of largest image only
        let largestImgUrl = imgUrls.last
        self.imgUrl = largestImgUrl?.label ?? ""
        
        let summaryContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .summary)
        self.summary = try summaryContainer.decode(String.self, forKey: .label)
        
        let categoryContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .category)
        let categoryLabel = try categoryContainer.decode(SubLabel.self, forKey: .attributes)
        self.category = categoryLabel.label
    }
}
