////
////  DetailViewController.swift
////  PictureProject
////
////  Created by Алик on 12.02.2026.
////
//
//import Foundation
//import UIKit
//class DetailViewController: UIViewController {
//    
//    private let favoritesService = FavoritesService.shared
//    private var currentPhoto: UnsplashPhoto?
//    private var favoritePhoto: FavoritePhoto?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupFavoriteButton()
//    }
//    
//    private func setupFavoriteButton() {
//        let isFavorite = favoritesService.isFavorite(id: photoID)
//        let heartImage = isFavorite ? "heart.fill" : "heart"
//        
//        let favoriteButton = UIBarButtonItem(
//            image: UIImage(systemName: heartImage),
//            style: .plain,
//            target: self,
//            action: #selector(toggleFavorite)
//        )
//        favoriteButton.tintColor = .white
//        navigationItem.rightBarButtonItem = favoriteButton
//    }
//    
//    @objc private func toggleFavorite() {
//        guard let photo = currentPhoto else { return }
//        
//        // Создаем объект для избранного
//        let favorite = FavoritePhoto(
//            id: photo.id,
//            authorName: photo.user.name,
//            authorUsername: photo.user.username,
//            smallImageURL: photo.urls.small,
//            regularImageURL: photo.urls.regular,
//            createdAt: Date()
//        )
//        
//        let isNowFavorite = favoritesService.toggleFavorite(favorite)
//        
//        // Обновляем иконку
//        let heartImage = isNowFavorite ? "heart.fill" : "heart"
//        navigationItem.rightBarButtonItem?.image = UIImage(systemName: heartImage)
//    }
//}
