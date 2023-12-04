//
//  ImagesList.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 22.11.2023.
//
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool
    
    init(photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt ?? "")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls["thumb"] ?? ""
        self.largeImageURL = photoResult.urls["full"] ?? ""
        self.isLiked = photoResult.likedByUser
    }
}
