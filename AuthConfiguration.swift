import Foundation

let AccessKey = "1y1jbLVflPe5rv7GBq5UA89Iw5M8UCx3qteKsLlCdvQ"
let SecretKey = "x8tgYjlAwHC5ZjGeeXgov_iNQx-4sIGbNLj5LTKcCig"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let TokenKey = "ImageFeed"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(accesccKey: AccessKey, secretKwy: SecretKey, redirectURI: RedirectURI, accessScope: AccessScope, defaultBaseURL: DefaultBaseURL, authURLString: UnsplashAuthorizeURLString)
    }

    init(accesccKey: String, secretKwy: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accesccKey
        self.secretKey = secretKwy
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
