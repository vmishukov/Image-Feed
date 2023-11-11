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
        
        let request = self.profileRequest(token: token)
        let task = self.urlSession.objectTask(for: request) { [weak self] ( result: Result<ProfileResult,Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let profile = Profile(profileResult: body)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
}


// MARK: - Network Connection
extension ProfileService {
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
