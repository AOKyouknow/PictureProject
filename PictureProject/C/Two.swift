//
//  Two.swift
//  HZ
//
//  Created by Алик on 01.10.2025.
//

import UIKit

//
//  FavoritesViewController.swift
//  HZ
//
//  Created by Алик on 12.02.2026.
//

import UIKit

class Two: UIViewController {
    
    // MARK: - Variables
    private var favorites: [FavoritePhoto] = []
    private let favoritesService = FavoritesService.shared
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(FavoriteTableViewCell.self,
                          forCellReuseIdentifier: FavoriteTableViewCell.identifier)
        tableView.rowHeight = 86
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет избранных фотографий"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        loadFavorites()
        
        // Подписываемся на обновления избранного
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidUpdate),
            name: .favoritesDidUpdate,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites() // Обновляем при каждом появлении экрана
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Избранное"
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Data
    private func loadFavorites() {
        favorites = favoritesService.getAllFavorites()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !favorites.isEmpty
        tableView.isHidden = favorites.isEmpty
    }
    
    // MARK: - Actions
    @objc private func favoritesDidUpdate() {
        loadFavorites()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension Two: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteTableViewCell.identifier,
            for: indexPath
        ) as? FavoriteTableViewCell else {
            return UITableViewCell()
        }
        
        let favorite = favorites[indexPath.row]
        cell.configure(with: favorite)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension Two: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let favorite = favorites[indexPath.row]
        // Переход на экран детальной информации
        let detailVC = DetailViewController(favorite: favorite)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Удаление свайпом
    func tableView(_ tableView: UITableView,
                  commit editingStyle: UITableViewCell.EditingStyle,
                  forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let favorite = favorites[indexPath.row]
            favoritesService.removeFromFavorites(byId: favorite.id)
            // Не вызываем loadFavorites, так как придет уведомление
        }
    }
    
    // Контекстное меню
    func tableView(_ tableView: UITableView,
                  contextMenuConfigurationForRowAt indexPath: IndexPath,
                  point: CGPoint) -> UIContextMenuConfiguration? {
        
        let favorite = favorites[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let deleteAction = UIAction(
                title: "Удалить из избранного",
                image: UIImage(systemName: "heart.slash"),
                attributes: .destructive
            ) { _ in
                self.favoritesService.removeFromFavorites(byId: favorite.id)
            }
            
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}
