//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Vladislav Mishukov on 27.11.2023.
//
@testable import Image_Feed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(forName: ImagesListService.DidChangeNotification,
                                               object: nil,
                                               queue: .main) { _ in
            expectation.fulfill()
        }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(service.photos.count, 10)
    }
}
