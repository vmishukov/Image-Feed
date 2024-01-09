//
//  ImageListViewTests.swift
//  Image FeedTests
//
//  Created by Vladislav Mishukov on 08.01.2024.
//

@testable import Image_Feed
import XCTest
import UIKit
import Foundation

final class ImagesListPresenterSpy: ImagesListViewPresenterProtocol {
 
    var view: Image_Feed.ImagesListViewControllerProtocol?
    var imagesListService: Image_Feed.ImagesListService
    var didSetLikeCall: Bool = false
    var viewDidLoadCalled = false
    
    
    init(imagesListService: ImagesListService){
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func fetchPhotosNextPage() {
    }
    func addPhotoLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        didSetLikeCall = true
    }
}
    
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: Image_Feed.ImagesListViewPresenterProtocol?
    var photos: [Image_Feed.Photo]
    
    init(photos: [Photo]) {
        self.photos = photos
    }
    
    func updateTableViewAnimated() {
    }
    func addPhotoLike() {
        presenter?.addPhotoLike(photoId: "photo", isLiked: true) { [weak self ] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                break
            case .failure(_):
                print("Invalid Configuration")
            }
        }
    }
}


final class ImageListViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad(){
         
        let imageListService = ImagesListService.shared
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
         let presenter = ImagesListPresenterSpy(imagesListService: imageListService)
         viewController.presenter = presenter
         presenter.view = viewController
         //when
         _ = viewController.view
         //then
         XCTAssertTrue(presenter.viewDidLoadCalled)
     }
    
    func testLike() {
        //given
        let photos: [Photo] = []
        let imagesListService = ImagesListService.shared
        let view = ImagesListViewControllerSpy(photos: photos)
        let presenter = ImagesListPresenterSpy(imagesListService: imagesListService)
        view.presenter = presenter
        presenter.view = view
        //when
        
        view.addPhotoLike()
        
        //then
        XCTAssertTrue(presenter.didSetLikeCall)
    }
    
}
