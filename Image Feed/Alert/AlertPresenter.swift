//
//  AlertPresenter.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 05.11.2023.
//

import Foundation

import UIKit
final class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
