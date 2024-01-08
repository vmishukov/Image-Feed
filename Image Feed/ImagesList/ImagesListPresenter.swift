//
//  ImageListPresenter.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 08.01.2024.
//

import Foundation

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? {get set}
    
    var imagesListService: ImagesListService {get}
    
    func viewDidLoad()
    func addPhotoLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func fetchPhotosNextPage()
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
        private var imagesListServiceObserver: NSObjectProtocol?
        let imagesListService = ImagesListService.shared
        
        func viewDidLoad() {
            configureNotificationObserver()
        }
        
        func addPhotoLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
                imagesListService.changeLike(photoId: photoId,
                                             isLiked: isLiked,
                                             { [weak self] result in
                    guard let self = self else { return }
                    switch result{
                    case .success(_):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                        print("\(error)")
                    }
                })
            }
    
        func configureNotificationObserver() {
            imagesListServiceObserver = NotificationCenter.default.addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    guard let self = self else { return }
                    view?.updateTableViewAnimated()
                }
            imagesListService.fetchPhotosNextPage()
        }
        
        func fetchPhotosNextPage(){
            imagesListService.fetchPhotosNextPage()
        }
}
