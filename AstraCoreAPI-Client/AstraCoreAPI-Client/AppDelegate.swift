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
		let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ?? ""
		AstraCoreAPI.coreAPI().configure(environment: .production, googleServiceInfo: plistPath)
		
		return AstraCoreAPI.coreAPI().application(
			application,
			didFinishLaunchingWithOptions: launchOptions
		)
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
	
	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]
	) -> Bool {
		return AstraCoreAPI.coreAPI().application(app, open: url, options: options)
	}
}
