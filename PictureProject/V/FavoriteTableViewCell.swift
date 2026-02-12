//
//  FavoriteTableViewCell.swift
//  PictureProject
//
//  Created by Алик on 12.02.2026.
//

import Foundation
import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    static let identifier = "FavoriteTableViewCell"
    
    // MARK: - UI Components
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(favoriteImageView)
        
        NSLayoutConstraint.activate([
            // Фото
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Имя автора
            authorLabel.topAnchor.constraint(equalTo: photoImageView.topAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: favoriteImageView.leadingAnchor, constant: -8),
            
            // Username
            usernameLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            
            // Иконка избранного
            favoriteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 20),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Configure
    func configure(with photo: FavoritePhoto) {
        authorLabel.text = photo.authorName
        usernameLabel.text = "@\(photo.authorUsername)"
        
        // Загружаем изображение
        if let image = photo.image {
            photoImageView.image = image
        } else {
            // Заглушка
            photoImageView.image = UIImage(systemName: "photo.fill")
            photoImageView.tintColor = .systemGray
            // Загружаем изображение асинхронно
            loadImage(from: photo.smallImageURL)
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.photoImageView.image = image
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        authorLabel.text = nil
        usernameLabel.text = nil
    }
}
