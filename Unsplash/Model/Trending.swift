//
//  Trending.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation

// MARK: - TrendingElement
struct Trending: Codable {
    var id: String?
    var width, height: Int?
    var color: String?
    var description: String?
    var alt_description: String?
    var urls: Urls?
    var links: TrendingLinks?
    var likes: Int?
    var liked_by_user: Bool?
    var user: User?
    var blur_hash: String?

    enum CodingKeys: String, CodingKey {
        case id
        case width, height, color
        case description = "description"
        case alt_description = "alt_description"
        case urls, links, likes
        case liked_by_user = "liked_by_user"
        case user
        case blur_hash = "blur_hash"
    }
}

// MARK: - TrendingLinks
struct TrendingLinks: Codable {
    var html, download, download_location: String?

    enum CodingKeys: String, CodingKey {
        case html, download
        case download_location = "download_location"
    }
}

// MARK: - Sponsorship
struct Sponsorship: Codable {
    var impression_urls: [String]?
    var tagline: String?
    var tagline_url: String?
    var sponsor: User?

    enum CodingKeys: String, CodingKey {
        case impression_urls = "impression_urls"
        case tagline
        case tagline_url = "tagline_url"
        case sponsor
    }
}

// MARK: - User
struct User: Codable {
    var id: String?
    var username, name, first_name: String?
    var last_name, twitter_username: String?
    var portfolio_url: String?
    var bio, location: String?
    var links: UserLinks?
    var profile_image: ProfileImage?
    var instagram_username: String?
    var total_collections, total_likes, total_photos: Int?
    var accepted_tos: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case username, name
        case first_name = "first_name"
        case last_name = "last_name"
        case twitter_username = "twitter_username"
        case portfolio_url = "portfolio_url"
        case bio, location, links
        case profile_image = "profile_image"
        case instagram_username = "instagram_username"
        case total_collections = "total_collections"
        case total_likes = "total_likes"
        case total_photos = "total_photos"
        case accepted_tos = "accepted_tos"
    }
}

// MARK: - UserLinks
struct UserLinks: Codable {
    var html, photos, likes: String?
    var portfolio, following, followers: String?

    enum CodingKeys: String, CodingKey {
        case html, photos, likes, portfolio, following, followers
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    var small, medium, large: String?
}

// MARK: - Urls
struct Urls: Codable {
    var raw, full, regular, small: String?
    var thumb: String?
}


