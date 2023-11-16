import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var alertPresener: AlertPresenterProtocol?
    private var splashImageView = UIImageView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = oAuth2TokenStorage.token else {
           switchToAuthViewController()
            return
        }
        fetchProfile(token)
        
    }
    
    private func fetchProfile(_ token: String) {
        //UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = self.profileService.profile?.userName else { return }
                profileImageService.fetchProfileImageURL(username) { _ in }
                self.switchToTabBarController()
            case .failure:
                self.showErrorAlert()
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#1A1B22")
        splashImageViewCreate()
        alertPresener = AlertPresenter(delegate: self)
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
    
    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewController")
        guard let authViewController = storyboard as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
        
    }
}
//MARK: - SplashViewController VC Elements
extension SplashViewController {
    private func splashImageViewCreate () {
        let profilePicture = UIImage(named: "splash_screen_logo")
        let imageView = UIImageView()
        imageView.image = profilePicture
        imageView.tintColor = .gray
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        splashImageViewConstraits(splashImageView: imageView)
        self.splashImageView = imageView
    }
    
    private func splashImageViewConstraits (splashImageView: UIView) {
        splashImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        splashImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        splashImageView.widthAnchor.constraint(equalToConstant: 73).isActive = true
        splashImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
}
//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
}
//MARK: - NetworkConnections
extension SplashViewController {
        private func fetchOAuthToken(_ code: String) {
            oauth2Service.fetchOAuthToken(code) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    let token = oAuth2TokenStorage.token
                    guard let token = token else {return}
                    fetchProfile(token)
                case .failure:
                    showErrorAlert()
                    break
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    
}
//MARK: - NetfowkErroAlert
extension SplashViewController {
    private func showErrorAlert() {
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
