//
//  PhotoStoreErrors.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

enum PhotoStoreErrors : Error {
    case invalidURLForPhoto
    case nilImgReturned
    case imgConversion
}
