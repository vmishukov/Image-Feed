//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 22.11.2023.
//

import UIKit

final class ImagesListService {
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    // MARK: - Public Properties
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var photos: [Photo] = []
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {
    }
    
    func fetchPhotosNextPage() -> Void {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        let request = imageRequest(token: token, page: nextPage, perPage: 10)
        let task = self.urlSession.objectTask(for: request) { [weak self]  (result: Result<[PhotoResult],Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                body.forEach { photoResult in
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self.dateFormatter.date(from: photoResult.createdAt ?? ""),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls?.thumbImageURL ?? "",
                        largeImageURL: photoResult.urls?.largeImageURL ?? "",
                        isLiked: photoResult.likedByUser ?? false)
                    self.photos.append(photo)
                }
                NotificationCenter.default
                    .post(name: ImagesListService.DidChangeNotification,
                          object: self,
                          userInfo: ["Images" : self.photos]
                    )
                self.task = nil
            case .failure(let error):
                self.task = nil
                assertionFailure("No images \(error)")
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        guard let token = OAuth2TokenStorage.shared.token else { return }
        let request = likeRequest(token: token, photoId: photoId, isLiked: isLiked)
        let task = self.urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult,Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                // Поиск индекса элемента
                if let index = self.photos.firstIndex(where: {$0.id == photoId}) {
                    //текущий элемент
                    //let photo = self.photos[index]
                    // Копия элемента с инвертированным значением isLiked
                    guard let newPhoto = body.photo else {return}
                    // заменяем элемент в массиве.
                    self.photos[index] = Photo(
                        id: newPhoto.id,
                        size: CGSize(width: newPhoto.width, height: newPhoto.height),
                        createdAt: self.dateFormatter.date(from: newPhoto.createdAt ?? ""),
                        welcomeDescription: newPhoto.description,
                        thumbImageURL: newPhoto.urls?.thumbImageURL ?? "",
                        largeImageURL: newPhoto.urls?.largeImageURL ?? "",
                        isLiked: newPhoto.likedByUser ?? false)
                    self.task = nil
                    completion(.success(Void()))
                }
                self.task = nil
            case .failure(let error):
                self.task = nil
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

// MARK: - Network Connection
extension ImagesListService {
    
    private func imageRequest(token: String, page: Int, perPage: Int) -> URLRequest {
        guard let url = URL(
            string: "\(DefaultBaseURL)"
            + "/photos"
            + "?page=\(page)"
            + "&&per_page=\(perPage)"
        )
        else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func likeRequest(token: String, photoId: String, isLiked: Bool) -> URLRequest {
        guard let url = URL(
            string: "\(DefaultBaseURL)"
            + "/photos"
            + "/\(photoId)"
            + "/like"
        )
        else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        
        if isLiked {
            request.httpMethod = "DELETE"
        }else {
            request.httpMethod = "POST"
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func withReplaced(itemAt: Int, newValue: Photo) -> [Photo] {
        var item = ImagesListService.shared.photos
        item.replaceSubrange(itemAt...itemAt, with: [newValue])
        return item
    }
}
