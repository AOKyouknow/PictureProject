//
//  FavoritesService.swift
//  PictureProject
//
//  Created by Алик on 12.02.2026.
//

import Foundation
import UIKit

protocol FavoritesServiceProtocol {
    func addToFavorites(_ photo: FavoritePhoto)
    func removeFromFavorites(byId id: String)
    func getAllFavorites() -> [FavoritePhoto]
    func isFavorite(id: String) -> Bool
    func toggleFavorite(_ photo: FavoritePhoto) -> Bool
}

final class FavoritesService: FavoritesServiceProtocol {
    
    static let shared = FavoritesService()
    private let userDefaultsKey = "favorite_photos"
    private let fileManager = FileManager.default
    
    private init() {}
    
    // MARK: - Public Methods
    
    func addToFavorites(_ photo: FavoritePhoto) {
        var favorites = getAllFavorites()
        
        // Проверяем, нет ли уже такого фото
        if !favorites.contains(where: { $0.id == photo.id }) {
            favorites.append(photo)
            saveFavorites(favorites)
            print("✅ Добавлено в избранное: \(photo.authorName)")
        }
    }
    
    func removeFromFavorites(byId id: String) {
        var favorites = getAllFavorites()
        favorites.removeAll { $0.id == id }
        saveFavorites(favorites)
        print("🗑 Удалено из избранного: \(id)")
    }
    
    func getAllFavorites() -> [FavoritePhoto] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }
        
        do {
            let favorites = try JSONDecoder().decode([FavoritePhoto].self, from: data)
            return favorites.sorted { $0.createdAt > $1.createdAt } // Сортировка: новые сверху
        } catch {
            print("❌ Ошибка загрузки избранного: \(error)")
            return []
        }
    }
    
    func isFavorite(id: String) -> Bool {
        let favorites = getAllFavorites()
        return favorites.contains { $0.id == id }
    }
    
    @discardableResult
    func toggleFavorite(_ photo: FavoritePhoto) -> Bool {
        if isFavorite(id: photo.id) {
            removeFromFavorites(byId: photo.id)
            return false
        } else {
            addToFavorites(photo)
            return true
        }
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites(_ favorites: [FavoritePhoto]) {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            // Отправляем уведомление об обновлении
            NotificationCenter.default.post(name: .favoritesDidUpdate, object: nil)
        } catch {
            print("❌ Ошибка сохранения избранного: \(error)")
        }
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let favoritesDidUpdate = Notification.Name("favoritesDidUpdate")
}
