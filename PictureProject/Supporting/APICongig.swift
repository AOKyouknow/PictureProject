//
//  APICongig.swift
//  PictureProject
//
//  Created by Алик on 12.02.2026.
//

import Foundation
//
//  APIConfig.swift
//  HZ
//
//  Created by Алик on 12.02.2026.
//



enum APIConfig {
    // Получаем ключи из Info.plist
    static var unsplashAccessKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
            fatalError("UnsplashAccessKey not found in Info.plist")
        }
        return key
    }
    
    static let baseURL = "https://api.unsplash.com"
}
