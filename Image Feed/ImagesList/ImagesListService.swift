//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 22.11.2023.
//

import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
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
                body.forEach { PhotoResult in
                    let photo = Photo(photoResult: PhotoResult)
                    self.photos.append(photo)
                }
                self.lastLoadedPage = nextPage
                NotificationCenter.default
                    .post(name: ImagesListService.DidChangeNotification,
                          object: self,
                          userInfo: ["Images" : self.photos]
                    )
                self.task = nil
            case .failure(let error):
                assertionFailure("No images \(error)")
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
}
