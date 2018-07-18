//
//  F2FAPIPayload.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

/// Used https://quicktype.io/ to generate model

struct SearchAPIResponse: Codable {
    let count: Int
    let recipes: [Recipe]
}


