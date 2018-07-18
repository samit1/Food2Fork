//
//  Recipe.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

/// Used https://quicktype.io/ to generate model 

struct Recipe: Codable {
    let publisher, f2FURL, title, sourceURL: String
    let recipeID, imageURL: String
    let socialRank: Double
    let publisherURL: String
    let uuid = NSUUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case publisher
        case f2FURL = "f2f_url"
        case title
        case sourceURL = "source_url"
        case recipeID = "recipe_id"
        case imageURL = "image_url"
        case socialRank = "social_rank"
        case publisherURL = "publisher_url"
    }
}
