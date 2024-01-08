//
//  ProfileResult.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 30.10.2023.
//
struct ProfileResult: Decodable {
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
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
    }
}
