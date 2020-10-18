//
//  UnsplashService.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation
import Moya

enum UnsplashService {
    case trending(page: Int)
    case search(q: String)
}

extension UnsplashService: TargetType {
    
    var baseURL: URL {
        switch self {
        case .trending:
            return URL(string: "https://api.unsplash.com")!
        case .search:
            return URL(string: "https://api.unsplash.com/search")!
        }
    }
    
    var path: String {
        switch self {
        case .trending:
            return "/photos"
        case .search:
            return "/photos"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .trending:
            return .get
        case .search:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .trending:
            return Data()
        case .search:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .trending(let page):
            return .requestParameters(parameters: ["client_id" : "YOUR CLIENT-ID", "order_by": "latest", "page": page], encoding: URLEncoding.queryString)
        case .search(let q):
            return .requestParameters(parameters: ["client_id" : "YOUR CLIENT-ID", "order_by" : "relevant", "query" : q], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }

}
