//
//  UIBlockingProgressHUD.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 29.10.2023.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate("Please wait...", .ballVerticalBounce)
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
