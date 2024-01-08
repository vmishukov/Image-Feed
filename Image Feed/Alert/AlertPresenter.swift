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
        
        let secondAction = UIAlertAction(title: model.secondButtonText, style: .default) { _ in
            model.secondCompletion()
        }
        alert.addAction(action)
        
        if model.secondButtonText != "" {
            alert.addAction(secondAction)
        }
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
