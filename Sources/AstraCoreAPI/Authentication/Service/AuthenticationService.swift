//
//  AuthenticationService.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Firebase
import Foundation
import GoogleSignIn
import KyuGenericExtensions

public struct AuthenticationService: AuthenticationServiceProtocol {
	public static var moduleName: String = "AstraCoreAPI.MediaLibraryService"
	public init() {}
	
	let userService = UserService()
}

public extension AuthenticationService {
	func sessionStatus(completion: @escaping (AuthenticationSessionStatusType) -> Void) {
		if let currentUser = Auth.auth().currentUser {
			let group = DispatchGroup()
			let userId = currentUser.uid
			
			if AstraCoreAPI.coreAPI().user == nil {
				group.enter()
				userService.getUser(by: userId) { result in
					switch result {
					case .success(let user):
						AstraCoreAPI.coreAPI().user = user
					case .failure:
						AstraCoreAPI.coreAPI().user = User(item: currentUser)
					}
					group.leave()
				}
			}
			
			if AstraCoreAPI.coreAPI().userSecret == nil {
				group.enter()
				userService.getUserSecret(by: userId) { result in
					switch result {
					case .success(let userSecret):
						AstraCoreAPI.coreAPI().userSecret = userSecret
					case .failure:
						AstraCoreAPI.coreAPI().userSecret = nil
					}
					group.leave()
				}
			}
			
			group.notify(queue: .main) {
				if let user = AstraCoreAPI.coreAPI().user {
					completion(.signedIn(user: user))
				} else {
					completion(.signedOut)
				}
			}
		} else {
			completion(.signedOut)
		}
	}
	
	func signInWithGoogle(
		presenting: UIViewController,
		completion: @escaping (Result<AuthenticationSessionStatusType, Error>) -> Void
	) {
		guard let clientID = FirebaseApp.app()?.options.clientID else { return }
		let configuration = GIDConfiguration(clientID: clientID)
		GIDSignIn.sharedInstance.signIn(
			with: configuration,
			presenting: presenting
		) { user, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let authentication = user?.authentication,
				  let idToken = authentication.idToken
			else {
				let error = AuthenticationServiceError(
					statusCode: 0,
					message: "AuthenticationService: IDToken not found."
				)
				completion(.failure(error))
				return
			}
			
			let credential = GoogleAuthProvider.credential(
				withIDToken: idToken,
				accessToken: authentication.accessToken
			)
			
			signIn(credential: credential, completion: completion)
		}
	}
	
	func signOut(completion: @escaping () -> Void) {
		try? Auth.auth().signOut()
		AstraCoreAPI.coreAPI().user = nil
		AstraCoreAPI.coreAPI().userSecret = nil
		completion()
	}
}

private extension AuthenticationService {
	func signIn(
		credential: AuthCredential,
		completion: @escaping (Result<AuthenticationSessionStatusType, Error>) -> Void
	) {
		Auth.auth().signIn(with: credential) { _, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			sessionStatus { status in
				completion(.success(status))
			}
		}
	}
}
