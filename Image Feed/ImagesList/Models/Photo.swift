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
}
