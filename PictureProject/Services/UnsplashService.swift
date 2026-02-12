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
    
    func fetchRandomPhotosAsync(count: Int) async throws -> [UIImage]
    
    func searchPhotosAsync(query: String, page: Int, perPage: Int) async throws -> [UIImage]
}                //конец протокола


class UnsplashService: UnsplashServiceProtocol {
    private let accessKey = APIConfig.unsplashAccessKey
    
    //MARK: - функция поиска
    func searchPhotosAsync(query: String, page: Int, perPage: Int) async throws -> [UIImage] {
        print("КЛЮЧ: \(accessKey)")
        print("ДЛИНА КЛЮЧА: \(accessKey.count)")
        // Формируем URL для поиска
        var components = URLComponents(string: "https://api.unsplash.com/search/photos")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        print("URL запроса: \(url)")
        // Создаем запрос
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        // Загружаем данные
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        print("HTTP статус поиска: \(httpResponse.statusCode)")
        
        // Если статус не 200, распечатать ошибку
        guard httpResponse.statusCode == 200 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("Ошибка API: \(errorString)")
            }
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }
        do{
            // Парсим JSON
            let searchResult = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
            print("Найдено результатов: \(searchResult.results.count)")
            print("Всего результатов: \(searchResult.total)")
            print("Всего страниц: \(searchResult.total_pages)")
            // Загружаем изображения
            var images: [UIImage] = []
            for photo in searchResult.results.prefix(perPage) {
                if let url = URL(string: photo.urls.small),
                   let (imageData, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: imageData) {
                    images.append(image)
                }
            }
            return images
        }catch {
            print("Ошибка декодинга: \(error)")
            throw error
        }
    }// конец функции поиска
    
    func fetchRandomPhotos(count: Int, completion: @escaping (Result<[UIImage], Error>) -> Void) {
        let urlString = "\(APIConfig.baseURL)/photos/random?count=\(count)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in //response нигде не используется, можно убрать и заменить на _
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
    
}// конец класса
