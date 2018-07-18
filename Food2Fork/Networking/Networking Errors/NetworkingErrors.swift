//
//  NetworkingErrors.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation


enum NetworkingErrors : Error {
    case invalidURLGenerated
    case apiReturnedError
    case invalidStatusCode
    case nilDataReturned
    case jsonProcessError 
}
