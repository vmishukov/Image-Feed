//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 11.11.2023.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keyChainWrapper = KeychainWrapper.standard

    private init() {}

    var token: String? {
        get {
            return keyChainWrapper.string(forKey: TokenKey)
        }
        set {
            guard let newValue = newValue  else { return }
            keyChainWrapper.set(newValue, forKey: TokenKey)
        }
    }
    func deleteToken() {
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: TokenKey)
    }
}
