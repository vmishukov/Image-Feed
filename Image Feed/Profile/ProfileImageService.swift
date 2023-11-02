//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 01.11.2023.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(_ username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if avatarURL != nil { return }
        task?.cancel()
        let request = makeRequest(code: username)
        let task = urlSession.dataTask(with: request) { date, response, error in
            DispatchQueue.main.async {
                guard let token = OAuth2TokenStorage().token else { return }
                let request = self.userResultsRequest(token: token,userName: username)
                let task = self.object(for: request) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let body):
                        let avatarURL = body.profileImage["small"]
                        self.avatarURL = avatarURL
                        completion(.success(avatarURL ?? ""))
                    case .failure(let error):
                        completion(.failure(error))
                    } }
            }
        }
        self.task = task
        task.resume()
    }
    
    
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: "...\(code)") else { fatalError("Failed to create URL")}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
}
// MARK: - Network Connection
extension ProfileImageService {
    
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<UserResults, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<UserResults, Error> in
                Result { try decoder.decode(UserResults.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func userResultsRequest(token: String, userName: String) -> URLRequest {
        guard let url = URL(
            string: "\(DefaultBaseURL)"
            + "/users/"
            + userName
        )
        else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
