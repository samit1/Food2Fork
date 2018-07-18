//
//  SearchEndPoint.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation


struct SearchEndPoint : EndPointType {
    let apiKey = (queryParamName: "key", apiKey: Constants.apiKey)
    
    let baseURL = Constants.baseURL
    
    let endPoint = F2FEndPoints.search.rawValue
}


