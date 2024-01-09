import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol { get set }

    func updateAvatar()
    func showLogOutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol = {
        return ProfileViewPresenter()
    }()
    
    
    @objc private func didTapButton(_ sender: UIButton) {
        showLogOutAlert()
    }
    // MARK: - private Properties
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var alertPresener: AlertPresenterProtocol?
    
    private lazy var logoutButton : UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.tintColor = UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        self.logoutButton = button
        return button
    }()
  
    private lazy var avatarImageView : UIImageView = {
        let profilePicture = UIImage(named: "profile_pick")
        let imageView = UIImageView()
        imageView.image = profilePicture
        imageView.tintColor = .gray
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }()
    private lazy var loginNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#AEAFB4")
        label.font = label.font.withSize(13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(13)
        label.textColor = UIColor.white
        view.addSubview(label)
        return label
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.viewDidLoad()
        
        setProfileConstraits()
        alertPresener = AlertPresenter(delegate: self)
        updateProfileDetails(profile: profileService.profile)
        view.backgroundColor = UIColor(hex: "#1A1B22")
       
        updateAvatar()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        loadNewAvatar(imageUrl: url)
        
    }
    
    private func setProfileConstraits() {
        logoutButtonConstraits(logoutButton: self.logoutButton)
        avatarImageViewConstraits(avatarImageView: self.avatarImageView)
        labelConstraits(Label: self.nameLabel, parentView: avatarImageView)
        labelConstraits(Label: self.loginNameLabel, parentView: self.nameLabel)
        labelConstraits(Label: self.descriptionLabel, parentView: loginNameLabel)
    }
    
    private func loadNewAvatar (imageUrl: URL) {
     
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
            
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: imageUrl,
                              placeholder: UIImage(named: "profile_pick"),
                              options: [.processor(processor)])
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 34
 
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        descriptionLabel.text = profile.bio
        loginNameLabel.text = profile.loginName
        nameLabel.text = profile.name
    }
    
    private func logoutButtonConstraits (logoutButton: UIView) {
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    private func avatarImageViewConstraits (avatarImageView: UIView) {
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
   private func labelConstraits (Label: UIView, parentView: UIView) {
        Label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        Label.topAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 8).isActive = true
    }

}

//MARK: - Logout alert
extension ProfileViewController {
    func showLogOutAlert() {
        let viewModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttonText: "Да",
            completion:  {[weak self] in
                guard let self = self else { return }
                presenter.exit()
                guard let window = UIApplication.shared.windows.first else {
                    fatalError("Invalid Configuration") }
                window.rootViewController = SplashViewController()
            },
            secondButtonText: "Нет",
            secondCompletion: {[weak self] in
                guard let self = self else { return }
                return
            }
        )
        alertPresener?.show(model: viewModel)
    }
    
    private func showErrorAlert() {
        let viewModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "Ок",
            completion:  {[weak self] in
                guard let self = self else { return }
                return
            })
        alertPresener?.show(model: viewModel)
    }
}
