//
//  FavoritePhoto.swift
//  PictureProject
//
//  Created by Алик on 12.02.2026.
//

import Foundation
import UIKit

struct FavoritePhoto: Codable {
    let id: String
    let authorName: String
    let authorUsername: String
    let smallImageURL: String
    let regularImageURL: String
    let createdAt: Date
    
    // Для сохранения самого изображения (опционально)
    var imageData: Data?
    
    // Вычисляемое свойство для UIImage
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    // Уникальный идентификатор для Equatable
    var uniqueIdentifier: String {
        return id
    }
}
