import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - private Properties
    private var logoutButton = UIButton()
    private let profileService = ProfileService.shared
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageViewCreate()
        logoutButtonCreate()
        //UIBlockingProgressHUD.show()
        updateProfileDetails(profile: profileService.profile)
        view.backgroundColor = UIColor(hex: "#1A1B22")
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        loadNewAvatar(imageUrl: url)
        
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
        nameLabelCreate(name: profile.name)
        loginNameLabelCreate(login: profile.loginName)
        descriptionLabelLabelCreate(bio: profile.bio)
    }
    
    private func descriptionLabelLabelCreate(bio: String) {
        let label = self.descriptionLabel
        label.text = bio
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(13)
        label.textColor = UIColor.white
        view.addSubview(label)
        labelConstraits(Label: label, parentView: loginNameLabel)
    }
    
   private func loginNameLabelCreate(login: String) {
        let label = self.loginNameLabel
        label.text = login
        label.textColor = UIColor(hex: "#AEAFB4")
        label.font = label.font.withSize(13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        labelConstraits(Label: label, parentView: nameLabel)
    }
    
    private func nameLabelCreate(name: String) {
        let label = self.nameLabel
        label.text = name
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        labelConstraits(Label: label, parentView: avatarImageView)
    }
    
   private func avatarImageViewCreate () {
        let profilePicture = UIImage(named: "profile_pick")
        let imageView = self.avatarImageView
        imageView.image = profilePicture
        imageView.tintColor = .gray
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageViewConstraits(avatarImageView: imageView)
    }
    
    private func logoutButtonCreate () {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.tintColor = UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        logoutButtonConstraits(logoutButton: button)
        self.logoutButton = button
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
    
    @objc
    private func didTapButton() {
    }
}
