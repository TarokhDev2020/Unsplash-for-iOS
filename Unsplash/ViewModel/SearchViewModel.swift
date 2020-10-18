//
//  SearchViewModel.swift
//  Unsplash
//
//  Created by Tarokh on 9/24/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation

class SearchViewModel {
    
    // define some variables
    fileprivate let service = SearchDataService()
    var searchItems = [SearchResult]()
    
    // define some functions
    func getSearchedImages(q: String, completion: @escaping (ViewModelState) -> Void) {
        service.getSearchedImages(q: q) { (search, err) in
            if let error = err {
                print(error)
                completion(.failure)
                return
            }
            for searchResult in search!.results {
                self.searchItems.append(searchResult)
            }
            completion(.success)
        }
    }
    
}
