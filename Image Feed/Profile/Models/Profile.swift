//
//  Profile.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 30.10.2023.
//
struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    
    init(profileResult: ProfileResult) {
        self.userName = profileResult.userName
        self.name = (profileResult.lastName ?? "") + " " + (profileResult.firstName ?? "")
        self.loginName = "@" + profileResult.userName
        self.bio = profileResult.bio ?? ""
    }
}
