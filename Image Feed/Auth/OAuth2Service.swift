import Foundation
import SwiftKeychainWrapper

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    


    func fetchOAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = makeRequest(code: code)
        let task = urlSession.dataTask(with: request) { date, response, error in
            DispatchQueue.main.async {
                let request = self.authTokenRequest(code: code)
                let task = self.urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let body):
                        let authToken = body.accessToken
                        let isSuccess = KeychainWrapper.standard.set(authToken, forKey: "Auth token")
                        guard isSuccess else { return }
                        
                        completion(.success(authToken))
                    case .failure(let error):
                        completion(.failure(error))
                    } }
                self.task = nil
                if error != nil {
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: "...\(code)") else { fatalError("Failed to create URL")}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
// MARK: - Network Connection

extension OAuth2Service {

    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        ) }
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
