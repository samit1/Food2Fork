//
//  PhotoStore.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation
import UIKit

/// Result of fetching photo
/// State can be a success or a failure
enum PhotoResult {
    case success(UIImage)
    case failure(Error)
}

/// Store which holds and fetches images
struct PhotoStore {
    // MARK: Public Methods
    
    /// Fetch photo on a background thread.
    /// When image is returned or fails to return, the completion handler will be called on the main thread.
    static func searchForPhoto(url: String, onCompletion: @escaping (PhotoResult) -> ()) {
        
        /// If image already exists in cache, then fetch, call completion handler, and exit
        let img = getObjectFromCache(for: url)
        guard img == nil else {
            DispatchQueue.main.async {
                onCompletion(.success(img!))
            }
            return
        }
        
        /// Build URL to fetch image
        guard let toURL = URL(string: url) else {
            onCompletion(.failure(PhotoStoreErrors.invalidURLForPhoto))
            return
        }
        
        /// Fetch image on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let data = try? Data(contentsOf: toURL) else {
                DispatchQueue.main.async {
                    onCompletion(.failure(PhotoStoreErrors.nilImgReturned))
                }
                return
            }
            
            guard let imageFetched = UIImage(data: data) else {
                DispatchQueue.main.async {
                    onCompletion(.failure(PhotoStoreErrors.imgConversion))
                }
                return
            }
            
            /// Call completion handler and add to cache
            DispatchQueue.main.async {
                addToCache(key: url, img: imageFetched)
                onCompletion(.success(imageFetched))
            }
        }
    }
    
    // MARK: Private methods
    
    /// Image cache
    private static var cache = NSCache<NSString, UIImage>()
    
    /// Add to cache
    private static func addToCache(key: String, img: UIImage) {
        cache.setObject(img, forKey: key as NSString)
    }
    
    /// Retrieve from cache
    private static func getObjectFromCache(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    /// Every method is static and creating an instance of the PhotoStore does not make sense.
    private init() {}
    
}
