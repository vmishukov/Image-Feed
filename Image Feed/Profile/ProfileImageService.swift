//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 01.11.2023.
//

import Foundation

final class ProfileImageService {
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
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
                let task = self.urlSession.objectTask(for: request) { [weak self] (result: Result<UserResults,Error> )in
                    guard let self = self else { return }
                    switch result {
                    case .success(let body):
                        let profileImageURL = body.profileImage["small"]
                        self.avatarURL = profileImageURL
                        completion(.success(profileImageURL ?? ""))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.DidChangeNotification,
                                object: self,
                                userInfo: ["URL": profileImageURL])
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
