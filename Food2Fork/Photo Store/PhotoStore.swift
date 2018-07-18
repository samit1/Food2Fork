//
//  PhotoStore.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation
import UIKit

enum PhotoResult {
    case success(UIImage)
    case failure(Error)
}

struct PhotoStore {
    
    private static var cache = NSCache<NSString, UIImage>()
    
    
    
    static func searchForPhoto(url: String, onCompletion: @escaping (PhotoResult) -> ()) {
        
        let img = getObjectFromCache(for: url)
        guard img == nil else {
            DispatchQueue.main.async {
                onCompletion(.success(img!))
            }
            
            return
        }
        
        guard let toURL = URL(string: url) else {
            DispatchQueue.main.async {
                onCompletion(.failure(PhotoStoreErrors.invalidURLForPhoto))
            }
            
            return
        }
        
        guard let data  = try? Data(contentsOf: toURL) else {
            DispatchQueue.main.async {
                onCompletion(.failure(PhotoStoreErrors.nilImgReturned))
            }
            
            return
        }
        
        guard let imgFetched = UIImage(data: data) else {
            DispatchQueue.main.async {
                onCompletion(.failure(PhotoStoreErrors.imgConversion))
            }
            
            return
        }
        
        DispatchQueue.main.async {
            addToCache(key: url, img: imgFetched)
            onCompletion(.success(imgFetched))
        }
        
        
    }
    
    private static func addToCache(key: String, img: UIImage) {
        cache.setObject(img, forKey: key as NSString)
    }
    
    private static func getObjectFromCache(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    private init() {} 
    
}
