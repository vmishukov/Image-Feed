import UIKit
import SwiftKeychainWrapper
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
   
    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
  
    private var alertPresener: AlertPresenterProtocol?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alertPresener = AlertPresenter(delegate: self)
      
        let token = KeychainWrapper.standard.string(forKey: "Auth token")
        if let token = token {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `Window` приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        
        // Cоздаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора.
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}



extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            
            // Доберёмся до первого контроллера в навигации. Мы помним, что в программировании отсчёт начинается с 0?
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let token = KeychainWrapper.standard.string(forKey: "Auth token")
                guard let token = token else {return}
                fetchProfile(token)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                // TODO [Sprint 11]
                UIBlockingProgressHUD.dismiss()
                showAlert()
                break
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                
                guard let userName = profileService.profile?.userName else { return }
                fetchProfileImageURL(userName)
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11]
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
    
    private func fetchProfileImageURL(_ userName: String) {
        profileImageService.fetchProfileImageURL(userName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print(profileImageService.avatarURL)
            case .failure:
                break
            }
        }
    }
    
    func showAlert() {
        let viewModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "Ок",
            completion:  {[weak self] in
                guard let self = self else { return }
                //действие
            })
        alertPresener?.show(model: viewModel)
    }
}
