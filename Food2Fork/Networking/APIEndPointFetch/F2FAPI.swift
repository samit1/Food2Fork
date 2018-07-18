//
//  F2FAPI.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation

enum Results {
    case success(APIResponse)
    case failure(Error)
}


struct F2FAPI {
    // MARK: Public methods
    
    /// Perform a search to the Food2Fork API
    /// - parameter query: The string to search for
    /// - parameter onCompletion: Completion handler to call when the API request has completed or failed.
    static func performSearch(for query: String, onCompletion: @escaping (Results) -> ()) {
        let params  = [
            "q" : query
        ]
        makeAPIRequest(to: .search, with: params) { (results) in
            DispatchQueue.main.async {
                onCompletion(results)
            }
        }
    }
    // MARK: Private methods
    
    /// Builds a url that can be used to make web service calls
    /// - parameter baseURL: The base URL for the api
    /// - parameter endPoint: The endpoint of the api
    /// - parameter parameters: Additional parameters that can be added to a URL
    /// - returns: a URL, if valid
    private static func buildAPIURL(apiKey: String,
                                    baseURL: String,
                                    endPoint: F2FEndPoints,
                            parameters: [String:String]) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.path = endPoint.rawValue
        var queryItems = [URLQueryItem]()
        let requiredParams = [
            "key" : apiKey
        ]
        
        for param in requiredParams {
            let queryItem = URLQueryItem(name: param.key, value: param.value)
            queryItems.append(queryItem)
        }
        
        for param in parameters {
            let queryItem = URLQueryItem(name: param.key, value: param.value)
            queryItems.append(queryItem)
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    /// Makes an API request and calls back a completion handler with results from the request
    /// Completion handler is called back on the main thread
    /// - parameter endPoint: The end point which the request is being made to
    /// - parameter parameters: Additional parameters that can be added to a URL
    /// - parameter onCompletion: Completion handler to call when the API request has completed or failed. 
    private static func makeAPIRequest(to endPoint: F2FEndPoints,
                               with parameters: [String:String],
                               onCompletion: @escaping (Results) -> ()) {
        
        /// Build URL for request
        guard let url = buildAPIURL(apiKey: Constants.apiKey, baseURL: Constants.baseURL, endPoint: endPoint, parameters: parameters) else {
            onCompletion(.failure(NetworkingErrors.invalidURLGenerated))
            return
        }
        /// Create URL Session
        let session = URLSession(configuration: .default)
        
        // TODO: Error handle timeout
        
        /// Create Request
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 15.0)
        
        /// Create data task using request
        _ = session.dataTask(with: request) { (data, response, error) in
            
            /// When results return, dispatch main thread
            DispatchQueue.main.async {
                
                /// Ensue no error returnd
                guard error == nil else {
                    onCompletion(.failure(NetworkingErrors.apiReturnedError))
                    return
                }
                
                /// Ensure correct status code was returned
                guard let urlResponse = response as? HTTPURLResponse,
                    urlResponse.statusCode == 200 else {
                    onCompletion(.failure(NetworkingErrors.invalidStatusCode))
                    return
                }
                
                /// Ensure data returned
                guard let data = data else {
                    onCompletion(.failure(NetworkingErrors.nilDataReturned))
                    return
                }
                
                /// Process data to data model object and call back completion handlers
                onCompletion(processData(data))
            }
        }.resume()
    }
    
    /// Process data to Results type
    private static func processData(_ data: Data) -> Results {
        do {
            let results = try JSONDecoder().decode(APIResponse.self, from: data)
            return .success(results)
        } catch {
            return .failure(NetworkingErrors.jsonProcessError)
        }
    }
    
    /// All methods and variables are static, this should not ever be initialized.
    private init() {}
}

