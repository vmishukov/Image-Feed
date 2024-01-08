//
//  ImagesListResults.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 22.11.2023.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: CGFloat
    let height: CGFloat
    let createdAt: String?
    let description: String?
    let urls: UrlsResult?
    let likedByUser: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
        case urls = "urls"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumbImageURL: String?
    let largeImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case thumbImageURL = "thumb"
        case largeImageURL = "full"
    }
}

struct LikeResult: Decodable {
    let photo: PhotoResult?

}
