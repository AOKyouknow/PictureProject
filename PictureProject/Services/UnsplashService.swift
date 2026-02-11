//
//  UnsplashService.swift
//  HZ
//
//  Created by Алик on 05.10.2025.
//


import UIKit
import Foundation

protocol UnsplashServiceProtocol {
    func fetchRandomPhotos(count: Int, completion: @escaping (Result<[UIImage], Error>) -> Void)
    
    // async метод
    func fetchRandomPhotosAsync(count: Int) async throws -> [UIImage]
    
    func searchPhotosAsync(query: String, page: Int, perPage: Int) async throws -> [UIImage]
}

//TODO: 1 - можно написать некий базовы класс, который будет выполнять роль основного сервиса, то есть если тебе потребуется с 10 экранов делать 10 запросов, чтобы не писать каждый раз один и тот же код, создавая URL.session, а, например, а) наследоваться от основного класса б) сделать некий сервис прослойку, который будет обращаться к основному сервису, прокидывая в него только урл и другие нужные данные. В то же время протокол по-прежнему нужен, это очень хорошо.
class UnsplashService: UnsplashServiceProtocol {
    //TODO: 3 - можно ли как-то безопасно хранить данный ключ?
    private let accessKey = "sA_clGtZeYnKVP67LxrqQgz1xfVJfgeUqsB4scBim7k"
    private let baseURL = "https://api.unsplash.com"
    
    //MARK: - функция поиска
    func searchPhotosAsync(query: String, page: Int, perPage: Int) async throws -> [UIImage] {
            // 1. Формируем URL для поиска
            var components = URLComponents(string: "https://api.unsplash.com/search/photos")!
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ]
            
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            
            // 2. Создаем запрос
            var request = URLRequest(url: url)
            request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
            
            // 3. Загружаем данные
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // 4. Парсим JSON
            let searchResult = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
            
            // 5. Загружаем изображения
            var images: [UIImage] = []
            for photo in searchResult.results.prefix(perPage) {
                if let url = URL(string: photo.urls.small),
                   let (imageData, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: imageData) {
                    images.append(image)
                }
            }
            
            return images
        }
    

    // MARK: - Models for Search
    struct UnsplashSearchResult: Codable {
        let total: Int
        let total_pages: Int
        let results: [UnsplashPhoto]
    }

    struct UnsplashPhoto: Codable {
        let id: String
        let urls: UnsplashPhotoURLs
    }

    struct UnsplashPhotoURLs: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    
    //MARK: - завершение функции поиска
    
    
    
    func fetchRandomPhotos(count: Int, completion: @escaping (Result<[UIImage], Error>) -> Void) {
        let urlString = "\(baseURL)/photos/random?count=\(count)" //TODO: 2 - отдельный билдер урлов, сервис ходит в сеть, он должен получать уже готовый урл, нужно разделять ответственность классов, один класс - одна задача
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))// перенёс перечисление в отдельный файл, но ничего не загорелось красным. Доступ остался.?????
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in //TODO: response нигде не используется, можно убрать и заменить на _
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let photos = try JSONDecoder().decode([UnsplashPhoto].self, from: data)
                self?.downloadImages(from: photos, completion: completion)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // async
    func fetchRandomPhotosAsync(count: Int) async throws -> [UIImage] {
        // Просто оборачиваем старый метод в async обертку
        return try await withCheckedThrowingContinuation { continuation in
            fetchRandomPhotos(count: count) { result in
                switch result {
                case .success(let images):
                    continuation.resume(returning: images)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    
    
    private func downloadImages(from photos: [UnsplashPhoto], completion: @escaping (Result<[UIImage], Error>) -> Void) {
        let group = DispatchGroup()
        var images: [UIImage] = []
        let lock = NSLock() // Для потокобезопасности
        
        for photo in photos {
            group.enter()
            guard let url = URL(string: photo.urls.small) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                if let data = data, let image = UIImage(data: data) {
                    lock.lock()
                    images.append(image)
                    lock.unlock()
                }
            }.resume()
        }
        
        group.notify(queue: .global(qos: .background)) {
            completion(.success(images))
        }
    }
    
    
    
    //ДОБАВЬТЕ
//    func searchPhotosAsync(query: String, page: Int, perPage: Int) async throws -> [UIImage] {
//        let urlString = "\(baseURL)/search/photos?query=\(query)&page=\(page)&per_page=\(perPage)"
//        
//        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
//        
//        let (data, _) = try await URLSession.shared.data(for: request)
//        let result = try JSONDecoder().decode(SearchResult.self, from: data)
//        
//        return try await downloadImagesAsync(from: result.results)
//    }
    
    // Добавьте эту структуру в конец файла UnsplashService
    struct SearchResult: Decodable {
        let results: [UnsplashPhoto]
    }
    
    
}
