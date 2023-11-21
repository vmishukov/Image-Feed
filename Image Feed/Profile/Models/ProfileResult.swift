//
//  ProfileResult.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 30.10.2023.
//
struct ProfileResult: Codable {
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
            case userName = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case bio = "bio"
        }
}
