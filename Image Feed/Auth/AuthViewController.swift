import UIKit

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    
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
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuth2Service.fetchAuthToken(code) { (complition: Result<String, Error>) in
            
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
