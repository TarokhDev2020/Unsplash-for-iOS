//
//  Search.swift
//  Unsplash
//
//  Created by Tarokh on 9/24/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation

// MARK: - Search
struct Search: Codable {
    var total: Int
    var total_pages: Int
    var results: [SearchResult]
}

struct SearchResult: Codable {
    var width: Int
    var height: Int
    var alt_description: String
    var urls: SearchURL
}

struct SearchURL: Codable {
    var raw: String
    var full: String
    var regular: String
    var small: String
    var thumb: String
}
