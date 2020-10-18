//
//  SearchDataService.swift
//  Unsplash
//
//  Created by Tarokh on 9/24/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation
import Moya

class SearchDataService {
    
    fileprivate let provider = MoyaProvider<UnsplashService>(endpointClosure: { (target: UnsplashService) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        switch target {
        default:
            let httpHeaderFields = ["Content-Type" : "charset=UTF-8"]
            return defaultEndpoint.adding(newHTTPHeaderFields: httpHeaderFields)
        }
    })
    
    func getSearchedImages(q: String ,completion: @escaping (Search?, Error?) -> Void) {
        provider.request(.search(q: q)) { (searchResponse) in
            switch searchResponse {
            case .success(let res):
                do {
                    let search = try JSONDecoder().decode(Search.self, from: res.data)
                    completion(search, nil)
                }
                catch let error as NSError {
                    completion(nil, error)
                }
            case .failure(let err):
                completion(nil, err)
            }
        }
    }
    
}
