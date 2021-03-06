//
//  AppStore.swift
//  Kuro
//
//  Created by Talha Rahman on 12/6/20.
//

import Foundation
import StoreKit

/// Responsible for handling AppStore review
struct AppStore {
    static let Defaults = UserDefaults.standard
    
    static func incrementLaunchCount() {
        guard var launchCount = Defaults.value(forKey: "launchCount") as? Int else {
            Defaults.set(1, forKey: "launchCount")
            return
        }
        launchCount += 1
        Defaults.set(launchCount, forKey: "launchCount")
    }
    
    /// Requests a review from user if app was launched 10, 50 or 100 times
    static func reviewIfApplicable() {
        switch Defaults.integer(forKey: "launchCount") {
        case 10, 50, 100:
            requestReview()
        default:
            print("App Launch Count: \(Defaults.integer(forKey: "launchCount"))")
        }
    }
    
    private static func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
