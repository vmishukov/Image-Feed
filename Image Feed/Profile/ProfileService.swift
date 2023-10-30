//
//  ProfileService.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 29.10.2023.
//

import UIKit

final class ProfileService {
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        if profile != nil { return }
        task?.cancel()
        let request = profileRequest(token: token)
        let task = self.object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let profile = Profile(profileResult: body)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            } }
        self.task = task
        task.resume()
    }
}
// MARK: - Network Connection
extension ProfileService {
    
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func profileRequest(token: String) -> URLRequest {
        guard let url = URL(
            string: "\(DefaultBaseURL)"
            + "/me")
        else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
