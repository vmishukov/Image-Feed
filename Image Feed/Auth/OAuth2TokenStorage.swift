import Foundation

final class OAuth2TokenStorage {
    init() {}
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
