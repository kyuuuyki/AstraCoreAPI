//
//  AuthenticationService.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuGenericExtensions

struct AuthenticationService {
}

extension AuthenticationService: AuthenticationServiceProtocol {
	func sessionStatus(completion: @escaping (AuthenticationSessionStatusType) -> Void) {
		if let apiKey = Keychain.keychain().get(KeychainKeyType.apiKey.rawValue) {
			completion(
				.signedIn(
					apiKey: apiKey,
					rateLimit: AstraCoreAPI.coreAPI().rateLimit,
					rateLimitRemaining: AstraCoreAPI.coreAPI().rateLimitRemaining
				)
			)
		} else {
			completion(.signedOut)
		}
	}
	
	func signIn(apiKey: String, completion: @escaping (Result<Bool, Error>) -> Void) {
		let mediaLibraryService = MediaLibraryService(apiKey: apiKey)
		mediaLibraryService.astromonyPictureOfTheDay(count: 1) { result in
			switch result {
			case .success:
				Keychain.keychain().set(apiKey, forKey: KeychainKeyType.apiKey.rawValue)
				completion(.success(true))
			case .failure(let error):
				Keychain.keychain().delete(KeychainKeyType.apiKey.rawValue)
				completion(.failure(error))
			}
		}
	}
	
	func signOut(completion: @escaping () -> Void) {
		Keychain.keychain().delete(KeychainKeyType.apiKey.rawValue)
		completion()
	}
}
