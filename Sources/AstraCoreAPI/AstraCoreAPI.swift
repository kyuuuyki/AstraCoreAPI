//
//  AstraCoreAPI.swift
//  AstraCoreAPI
//

import AstraCoreModels
import FirebaseCore
import Foundation
import KeychainSwift
import KyuGenericExtensions
import KyuNetworkExtensions
import Moya

public class AstraCoreAPI {
	// MARK: Instance
	private init() {}
	private static let shared = AstraCoreAPI()
	
	public static func coreAPI() -> AstraCoreAPI {
		return shared
	}
	
	// MARK: Properties
	public var rateLimit = 0
	public var rateLimitRemaining = 0
	
	private var apiKey: String {
		Keychain.keychain().get(KeychainKeyType.apiKey.rawValue) ?? ""
	}
	
	// MARK: Configuration
	public func configure(googleServiceInfo plistPath: String) {
		if let options = FirebaseOptions(contentsOfFile: plistPath) {
			FirebaseApp.configure(options: options)
		}
	}
	
	public func updateRateLimitRemaining(response: Response) {
		if let rateLimitString = response.response?.value(
			forHTTPHeaderField: "X-RateLimit-Limit"
		) {
			rateLimit = Int(rateLimitString) ?? 0
		}
		
		if let rateLimitRemainingString = response.response?.value(
			forHTTPHeaderField: "X-RateLimit-Remaining"
		) {
			rateLimitRemaining = Int(rateLimitRemainingString) ?? 0
		}
	}
}

public extension AstraCoreAPI {
	func authenticationService() -> AuthenticationServiceProtocol {
		return AuthenticationService()
	}
	
	func mediaLibraryService() -> MediaLibraryServiceProtocol {
		return MediaLibraryService(apiKey: apiKey)
	}
}

class Keychain {
	static let shared = KeychainSwift()
	static func keychain() -> KeychainSwift {
		return shared
	}
}
