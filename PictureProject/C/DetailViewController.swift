//
//  DetailViewController.swift
//  PictureProject
//
//  Created by Алик on 12.02.2026.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    private let photoID: String
    private var currentPhoto: UnsplashPhoto?
    private let favoritesService = FavoritesService.shared
    
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .systemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init(photoID: String) {
        self.photoID = photoID
        super.init(nibName: nil, bundle: nil)
    }
    
    // Для избранного
    init(favorite: FavoritePhoto) {
        self.photoID = favorite.id
        super.init(nibName: nil, bundle: nil)
        
        // Заполняем данными из избранного
        authorLabel.text = favorite.authorName
        usernameLabel.text = "@\(favorite.authorUsername)"
        
        if let image = favorite.image {
            imageView.image = image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFavoriteButton()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Фото"
        
        view.addSubview(imageView)
        view.addSubview(authorLabel)
        view.addSubview(usernameLabel)
        view.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            authorLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            usernameLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor)
        ])
    }
    
    private func setupFavoriteButton() {
        let isFavorite = favoritesService.isFavorite(id: photoID)
        let heartImage = isFavorite ? "heart.fill" : "heart"
        
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: heartImage),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        favoriteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    @objc private func toggleFavorite() {
        guard let photo = currentPhoto else { return }
        
        let favorite = FavoritePhoto(
            id: photo.id,
            authorName: photo.user.name,
            authorUsername: photo.user.username,
            smallImageURL: photo.urls.small,
            regularImageURL: photo.urls.regular,
            createdAt: Date(),
            imageData: imageView.image?.jpegData(compressionQuality: 0.8)
        )
        
        let isNowFavorite = favoritesService.toggleFavorite(favorite)
        let heartImage = isNowFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: heartImage)
    }
}
