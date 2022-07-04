//
//  AuthenticationService.swift
//  AstraCoreAPI
//

import AstraCoreModels
import FacebookLogin
import Firebase
import Foundation
import GoogleSignIn
import KyuGenericExtensions

private let profileImageSize = CGSize(width: 640, height: 640)

public struct AuthenticationService: AuthenticationServiceProtocol {
	public static var moduleName: String = "AstraCoreAPI.MediaLibraryService"
	public init() {}
	
	private let userService = UserService()
	
	// MARK: - GET SESSION STATUS
	public func getSessionStatus(completion: @escaping (AuthenticationSessionStatusType) -> Void) {
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
	
	// MARK: - SIGN IN WITH FACEBOOK
	public enum SignInWithFacebookError: Error {
		case tokenStringNotFound
		case cancelled
	}
	public func signInWithFacebook(
		presenting: UIViewController,
		completion: @escaping (
			Result<AuthenticationSessionStatusType, Error>
		) -> Void
	) {
		let loginManager = LoginManager()
		loginManager.logIn(
			permissions: ["email", "public_profile"],
			from: presenting
		) { result, error in
			if let error = error {
				completion(.failure(error))
			} else if let result = result, result.isCancelled {
				completion(.failure(SignInWithFacebookError.cancelled))
			} else {
				guard let tokenString = AccessToken.current?.tokenString else {
					completion(.failure(SignInWithFacebookError.tokenStringNotFound))
					return
				}
				
				let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
				signIn(credential: credential, completion: completion)
			}
		}
	}
	
	// MARK: - SIGN IN WITH GOOGLE
	public enum SignInWithGoogleError: Error {
		case idTokenNotFound
	}
	public func signInWithGoogle(
		presenting: UIViewController,
		completion: @escaping (
			Result<AuthenticationSessionStatusType, Error>
		) -> Void
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
				completion(.failure(SignInWithGoogleError.idTokenNotFound))
				return
			}
			
			let credential = GoogleAuthProvider.credential(
				withIDToken: idToken,
				accessToken: authentication.accessToken
			)
			signIn(credential: credential, completion: completion)
		}
	}
	
	// MARK: - SIGN OUT
	public func signOut(completion: @escaping () -> Void) {
		try? Auth.auth().signOut()
		AstraCoreAPI.coreAPI().user = nil
		AstraCoreAPI.coreAPI().userSecret = nil
		completion()
	}
}

private extension AuthenticationService {
	func signIn(
		credential: AuthCredential,
		completion: @escaping (
			Result<AuthenticationSessionStatusType, Error>
		) -> Void
	) {
		Auth.auth().signIn(with: credential) { _, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			let group = DispatchGroup()
			group.enter()
			updateCurrentUserData(credential: credential) {
				group.leave()
			}
			
			group.notify(queue: .main) {
				getSessionStatus { status in
					completion(.success(status))
				}
			}
		}
	}
	
	func updateCurrentUserData(credential: AuthCredential, completion: @escaping () -> Void) {
		if let currentUser = Auth.auth().currentUser, let user = User(item: currentUser) {
			var email: String?
			var imageUrl: URL?
			switch credential.provider {
			case "google.com":
				email = user.email
				imageUrl = GIDSignIn
					.sharedInstance
					.currentUser?
					.profile?
					.imageURL(withDimension: UInt(profileImageSize.height))
			case "facebook.com":
				for data in currentUser.providerData where !(data.email?.isEmpty ?? true) {
					email = data.email
					break
				}
				if let url = user.imageUrl {
					let queryItems = [
						URLQueryItem(
							name: "access_token",
							value: AccessToken.current?.tokenString
						),
						URLQueryItem(
							name: "width",
							value: "\(UInt(profileImageSize.width))"
						),
						URLQueryItem(
							name: "height",
							value: "\(UInt(profileImageSize.height))"
						),
					]
					var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true)
					urlComps?.queryItems = queryItems
					imageUrl = urlComps?.url
				}
			default:
				break
			}
			
			let updatedUser = User(
				id: user.id,
				displayName: user.displayName,
				email: email,
				imageUrl: imageUrl
			)
			
			userService.updateUser(user: updatedUser) { _ in
				completion()
			}
		} else {
			completion()
		}
	}
}
