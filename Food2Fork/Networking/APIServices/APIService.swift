//
//  F2FAPI.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import Foundation


enum Results  {
    case success(SearchAPIResponse)
    case failure(Error)
}

/// API Service loosly based off: https://medium.com/flawless-app-stories/writing-network-layer-in-swift-protocol-oriented-approach-4fa40ef1f908

/// QUESTION: Is it common to make my APIService struct completely static?
struct APIService {
    // MARK: Public methods
    
    
    /// QUESTION: I end up with some layered completion handlers, the performSearch takes a completion handler and then the makeAPI request also takes a completion handler. Is this a correct implementation? 
    /// Perform a search to the Food2Fork API
    /// - parameter query: The string to search for
    /// - parameter onCompletion: Completion handler to call when the API request has completed or failed.
    static func performSearch(for query: String,
                              onCompletion: @escaping (Results) -> ()) {
        let params : [String : String]  = [
            "q":query
        ]
        
        let endPoint = SearchEndPoint()
        
        makeAPIRequest(to: endPoint, with: params) { (results) in
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
    private static func buildAPIURL(endpoint: EndPointType,
                                    parameters: [String:String]) -> URL? {
        var components = URLComponents(string: endpoint.baseURL)
        components?.path = endpoint.endPoint
        var queryItems = [URLQueryItem]()
        let apiQueryItem = URLQueryItem(name: endpoint.apiKey.queryParamName, value: endpoint.apiKey.apiKey)
        queryItems.append(apiQueryItem)
        
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
    private static func makeAPIRequest(to endPoint: EndPointType,
                               with parameters: [String:String],
                               onCompletion: @escaping (Results) -> ()) {
        
        /// Build URL for request
        guard let url = buildAPIURL(endpoint: endPoint, parameters: parameters ) else {
            onCompletion(.failure(NetworkingErrors.invalidURLGenerated))
            return
        }
        /// Create URL Session
        let session = URLSession(configuration: .default)
                
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
            let results = try JSONDecoder().decode(SearchAPIResponse.self, from: data)
            return .success(results)
        } catch {
            return .failure(NetworkingErrors.jsonProcessError)
        }
    }
    
    /// All methods and variables are static, this should not ever be initialized.
    private init() {}
}

