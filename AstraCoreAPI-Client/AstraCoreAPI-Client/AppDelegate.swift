//
//  AppDelegate.swift
//  AstraCoreAPI-Client
//

import AstraCoreAPI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		if let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
			AstraCoreAPI.coreAPI().configure(googleServiceInfo: plistPath)
		}
		
		return true
	}
	
	// MARK: UISceneSession Lifecycle
	
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		return UISceneConfiguration(
			name: "Default Configuration",
			sessionRole: connectingSceneSession.role
		)
	}
	
	func application(
		_ application: UIApplication,
		didDiscardSceneSessions
		sceneSessions: Set<UISceneSession>
	) {
	}
}
