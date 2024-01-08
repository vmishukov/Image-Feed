//
//  ProfileViewTests.swift
//  Image FeedTests
//
//  Created by Vladislav Mishukov on 08.01.2024.
//

@testable import Image_Feed
import XCTest
import Foundation
import UIKit

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var observer: Bool = false
    var viewDidClearDetailsAccount: Bool = false
    var didLogoutCalled: Bool = false
    var profileService: Image_Feed.ProfileService
    
    init(profileService: ProfileService){
        self.profileService = profileService
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func exit() {
        viewDidClearDetailsAccount = true
        didLogoutCalled = true
    }
    
    func profileServiceObserver() {
        observer = true
    }
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: Image_Feed.ProfileViewPresenterProtocol
    
    var nameLabel = UILabel()
    var loginNameLabel = UILabel()
    var descriptionLabel = UILabel()
    var updatedAvatar: Bool = false
    var viewDidUpdateProfileDetails: Bool = false
    
    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
    }
    
    func showLogOutAlert() {
        presenter.exit()
    }
  
    func updateAvatar() {
        updatedAvatar = true
    }

    func updateProfileDetails(profile: Image_Feed.Profile?) {
        viewDidUpdateProfileDetails = true
        guard let profile = profile else { return }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
}


final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let profileService = ProfileService.shared
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsCleanCookies() {
        //given
        
        let profileService = ProfileService.shared
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenterSpy(profileService: profileService)
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        //when
        _ = profileViewController.view
        profilePresenter.exit()
        
        //then
        XCTAssertTrue(profilePresenter.viewDidClearDetailsAccount)
    }
    
    
    func testPresenterCallsUpdateProfile() {
        let profileService = ProfileService.shared
        //given
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        let profileViewController = ProfileViewControllerSpy(presenter: presenter)
        let profilePresenter = ProfileViewPresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        let test = "Это тестовый тест для био"
        let userName = "test"
        let nameLabel = "Testovich Test"
        let firstName = "Test"
        let lastName = "Testovich"
        let loginNameLabel = "@test"
        let profile = Profile(profileResult: ProfileResult(userName: userName,
                                                        firstName: firstName,
                                                      lastName: lastName,
                                                      bio: test))
        
        //when
        profileViewController.updateProfileDetails(profile: profile)
        
        //then
        XCTAssertTrue(profileViewController.viewDidUpdateProfileDetails)
        XCTAssertEqual(profileViewController.nameLabel.text, nameLabel)
        XCTAssertEqual(profileViewController.loginNameLabel.text, loginNameLabel)
        XCTAssertEqual(profileViewController.descriptionLabel.text, test)
    }
    
    func testExitProfile() {
        //given
        
        let profileService = ProfileService.shared
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        let view = ProfileViewControllerSpy(presenter: presenter)
        view.presenter = presenter
        presenter.view = view
        
        //when
        view.showLogOutAlert()
        
        //then
        XCTAssertTrue(presenter.didLogoutCalled)
    }
}




