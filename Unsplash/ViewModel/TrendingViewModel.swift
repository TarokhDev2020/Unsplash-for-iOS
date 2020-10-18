//
//  TrendingViewModel.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation
import Moya

class TrendingViewModel {
    
    // define some variables
    fileprivate let service = TrendingDataService()
    var trendingItems = [Trending]()
    
    // define some functions
    func getTrendingImages(page: Int ,completion: @escaping (ViewModelState) -> Void) {
        service.getTrendingData(page: page) { (trending, err) in
            if let error = err {
                print(error)
                completion(.failure)
                return
            }
            for trendings in trending! {
                self.trendingItems.append(trendings)
                completion(.success)
            }
        }
    }
    
}
