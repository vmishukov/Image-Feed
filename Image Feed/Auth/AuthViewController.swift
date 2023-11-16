import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}


// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { result in
            switch result {
            case .success(let bearerToken):
                let token = bearerToken
                let isSuccess = OAuth2TokenStorage.shared.token
                guard (isSuccess != nil) else {
                    // ошибка
                    return
                }
                //                     self.switchToTabBarController()
                switchToSplashScreen()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        func switchToSplashScreen() {
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
            let splashScreenViewController = SplashViewController()
            window.rootViewController = splashScreenViewController
        }
    }
}
