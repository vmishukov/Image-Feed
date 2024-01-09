//
//  ProfileViewPresenter.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 08.01.2024.
//

import Foundation
import WebKit
import UIKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func exit()
    func profileServiceObserver()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        profileServiceObserver()
    }
    
    func exit() {
        Cookie.clean()
        OAuth2TokenStorage.shared.deleteToken()
        profileService.clean()
            
    }
    
    func profileServiceObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            view?.updateAvatar()
        }
        view?.updateAvatar()
    }
    
}
