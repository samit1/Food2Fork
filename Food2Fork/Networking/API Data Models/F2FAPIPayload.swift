//
//  F2FAPIPayload.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

struct APIResponse: Codable {
    let count: Int
    let recipes: [Recipe]
}


