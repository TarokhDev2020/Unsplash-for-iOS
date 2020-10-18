//
//  UnsplashDataService.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation
import Moya

class TrendingDataService {
    
    fileprivate let provider = MoyaProvider<UnsplashService>(endpointClosure: { (target: UnsplashService) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        switch target {
        default:
            let httpHeaderFields = ["Content-Type" : "charset=UTF-8"]
            return defaultEndpoint.adding(newHTTPHeaderFields: httpHeaderFields)
        }
    })
    
    func getTrendingData(page: Int ,completion: @escaping ([Trending]?, Error?) -> Void) {
        provider.request(.trending(page: page)) { (trendingResponse) in
            switch trendingResponse {
            case .success(let res):
                do {
                    let trending = try JSONDecoder().decode([Trending].self, from: res.data)
                    completion(trending, nil)
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
