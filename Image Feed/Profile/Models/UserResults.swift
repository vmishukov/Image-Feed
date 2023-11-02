//
//  UserResults.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 01.11.2023.
//

import Foundation
struct UserResults: Codable {
    let profileImage: [String: String]
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
