//
//  AstraCoreAPI.swift
//  AstraCoreAPI
//

import AstraCoreModels
import FacebookCore
import Firebase
import FirebaseFirestore
import Foundation
import GoogleSignIn
import KyuGenericExtensions
import KyuNetworkExtensions
import Moya
import UIKit

public class AstraCoreAPI {
	public enum Environment {
		case develop
		case staging
		case production
	}
	
	// MARK: Instance
	private init() {}
	private static let shared = AstraCoreAPI()
	
	public static func coreAPI() -> AstraCoreAPI {
		return shared
	}
	
	// MARK: Configuration
	public func configure(environment: Environment, googleServiceInfo plistPath: String) {
		self.environment = environment
		self.googleServiceInfoPlistPath = plistPath
	}
	
	public func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		// Facebook
		ApplicationDelegate.shared.application(
			application,
			didFinishLaunchingWithOptions: launchOptions
		)
		
		// Firebase
		if let options = FirebaseOptions(contentsOfFile: googleServiceInfoPlistPath) {
			FirebaseApp.configure(options: options)
		}
		
		return true
	}
	
	public func application(
		_ application: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]
	) -> Bool {
		// Facebook
		ApplicationDelegate.shared.application(
			application,
			open: url,
			sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
			annotation: options[UIApplication.OpenURLOptionsKey.annotation]
		)
		
		// Firebase
		GIDSignIn.sharedInstance.handle(url)
		
		return true
	}
	
	public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else {
			return
		}
		
		// Facebook
		ApplicationDelegate.shared.application(
			UIApplication.shared,
			open: url,
			sourceApplication: nil,
			annotation: [UIApplication.OpenURLOptionsKey.annotation]
		)
	}
	
	// MARK: Variables
	public var environment: Environment = .production
	public var googleServiceInfoPlistPath = ""
	
	public var user: UserProtocol?
	public var userSecret: UserSecretProtocol?
}
