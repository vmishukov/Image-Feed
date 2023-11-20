import Foundation

final class OAuth2Service {
    // MARK: - Public Properties
    static let shared = OAuth2Service()
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    
    private init(task: URLSessionTask? = nil, lastCode: String? = nil) {
        self.task = task
        self.lastCode = lastCode
    }
    
    func fetchOAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else { return }
        let task = urlSession.objectTask(for: request) {
            [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch response {
            case .success(let body):
                let authToken = body.accessToken
                self.oAuth2TokenStorage.token = authToken
                completion(.success(authToken))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

// MARK: - Network Connection

extension OAuth2Service {

    private func authTokenRequest(code: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    } }
