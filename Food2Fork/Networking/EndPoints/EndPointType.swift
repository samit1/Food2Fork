//
//  EndPointType.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

protocol EndPointType {
    var baseURL: String {get}
    var endPoint: String {get}
    var apiKey: (queryParamName: String, apiKey: String) {get}
}
