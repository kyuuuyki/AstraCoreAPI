//
//  AstraCoreAPI.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Firebase
import FirebaseFirestore
import Foundation
import GoogleSignIn
import KeychainSwift
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
		return GIDSignIn.sharedInstance.handle(url)
	}
	
	// MARK: Variables
	public var environment: Environment = .production
	public var googleServiceInfoPlistPath = ""
	
	public var user: UserProtocol?
	public var userSecret: UserSecretProtocol? {
		didSet {
			if let userSecret = userSecret {
				Keychain.keychain().set(
					userSecret.dataGovAPIKey,
					forKey: KeychainKeyType.dataGovAPIKey.rawValue
				)
			} else {
				Keychain.keychain().delete(KeychainKeyType.dataGovAPIKey.rawValue)
			}
		}
	}
}

class Keychain {
	static let shared = KeychainSwift()
	static func keychain() -> KeychainSwift {
		return shared
	}
}
