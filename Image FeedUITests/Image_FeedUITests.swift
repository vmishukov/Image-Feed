//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Vladislav Mishukov on 05.01.2024.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    private let email = ""
    private let password = ""
    
    private let fullNameLabel = ""
    private let userNameLabel = ""

    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
        
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    // тестируем сценарий авторизации
    func testAuth() {
    
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(email)
        
        webView.swipeUp()
        app.toolbars.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(password)
        
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(3)
        
        let cellToLike = tablesQuery.descendants(matching: .cell).element(boundBy: 1)
        
        let likeButton = cellToLike.descendants(matching: .button).element(boundBy: 0)
        
        likeButton.tap()
        
        sleep(2)
        
        likeButton.tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(3)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["scroll_view_back"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["\(fullNameLabel)"].exists)
        XCTAssertTrue(app.staticTexts["\(userNameLabel)"].exists)
        
        app.buttons["ipad.and.arrow.forward"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
