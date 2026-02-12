//
//  Search Models.swift
//  PictureProject
//
//  Created by Алик on 12.02.2026.
//

import Foundation
// MARK: - Models for Search
struct UnsplashSearchResult: Decodable {
    let total: Int
    let total_pages: Int
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Decodable {
    let id: String
    let urls: UnsplashPhotoURLs
    let user: User
}

struct UnsplashPhotoURLs: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct SearchResult: Decodable {
    let results: [UnsplashPhoto]
}
