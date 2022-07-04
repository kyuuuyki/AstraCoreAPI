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
	
	// MARK: - GET SESSION STATUS
	public func getSessionStatus(completion: @escaping (AuthenticationSessionStatusType) -> Void) {
		if let currentUser = Auth.auth().currentUser {
			let group = DispatchGroup()
			let userID = currentUser.uid
			let userService = UserService()
			
			if AstraCoreAPI.coreAPI().user == nil {
				group.enter()
				userService.getUser(by: userID) { result in
					switch result {
					case .success(let user):
						AstraCoreAPI.coreAPI().user = user
					case .failure:
						AstraCoreAPI.coreAPI().user = nil
					}
					group.leave()
				}
			}
			
			if AstraCoreAPI.coreAPI().userSecret == nil {
				group.enter()
				userService.getUserSecret(by: userID) { result in
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
	
	// MARK: - SIGN IN
	public enum SignInError: Error {
		case cancelled
		case tokenNotFound
	}
	public func signIn(
		provider: AuthenticationProviderType,
		presenting: UIViewController,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		switch provider {
		case .facebook:
			signInWithFacebook(presenting: presenting, completion: completion)
		case .google:
			signInWithGoogle(presenting: presenting, completion: completion)
		}
	}
	
	// MARK: - SIGN OUT
	public func signOut(completion: @escaping () -> Void) {
		try? Auth.auth().signOut()
		AstraCoreAPI.coreAPI().user = nil
		AstraCoreAPI.coreAPI().userSecret = nil
		completion()
	}
	
	// MARK: - REGISTER
	public enum RegisterError: Error {
		case dataGovAPIKeyInvalid
	}
	public func register(
		user: UserProtocol,
		userSecret: UserSecretProtocol,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		let group = DispatchGroup()
		
		group.enter()
		var isDataGovAPIKeyValid = false
		verifyDataGovAPIKey(apiKey: userSecret.dataGovAPIKey) { validationResult in
			isDataGovAPIKeyValid = validationResult
			group.leave()
		}
		
		group.notify(queue: .main) {
			guard isDataGovAPIKeyValid else {
				completion(.failure(RegisterError.dataGovAPIKeyInvalid))
				return
			}
			
			let userService = UserService()
			userService.setUser(user: user) { result in
				switch result {
				case .success:
					userService.setUserSecret(userSecret: userSecret) { result in
						switch result {
						case .success:
							completion(.success(()))
						case .failure(let error):
							completion(.failure(error))
						}
					}
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}
	
	// MARK: - UNREGISTER
	public enum UnregisterError: Error {
		case notSignedIn
	}
	public func unregister(
		presenting: UIViewController,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		getSessionStatus { status in
			switch status {
			case .signedIn(let user):
				if let currentUser = Auth.auth().currentUser {
					currentUser.delete(completion: { error in
						if let error = error {
							switch AuthErrorCode.Code(rawValue: (error as NSError).code) {
							case .requiresRecentLogin:
								signIn(provider: user.provider, presenting: presenting) { _ in
									unregister(presenting: presenting, completion: completion)
								}
							default:
								completion(.failure(error))
							}
						} else {
							signOut {
								completion(.success(()))
							}
						}
					})
				} else {
					completion(.failure(UnregisterError.notSignedIn))
				}
			case .signedOut:
				completion(.failure(UnregisterError.notSignedIn))
			}
		}
	}
}

// MARK: - PRIVATE EXTENSION
private extension AuthenticationService {
	// MARK: SIGN IN WITH FACEBOOK
	func signInWithFacebook(
		presenting: UIViewController,
		completion: @escaping (
			Result<Void, Error>
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
				completion(.failure(SignInError.cancelled))
			} else {
				guard let tokenString = AccessToken.current?.tokenString else {
					completion(.failure(SignInError.tokenNotFound))
					return
				}
				
				let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
				signIn(credential: credential, completion: completion)
			}
		}
	}
	
	// MARK: SIGN IN WITH GOOGLE
	func signInWithGoogle(
		presenting: UIViewController,
		completion: @escaping (
			Result<Void, Error>
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
				completion(.failure(SignInError.tokenNotFound))
				return
			}
			
			let credential = GoogleAuthProvider.credential(
				withIDToken: idToken,
				accessToken: authentication.accessToken
			)
			signIn(credential: credential, completion: completion)
		}
	}
	
	// MARK: SIGN IN
	func signIn(
		credential: AuthCredential,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		Auth.auth().signIn(with: credential) { _, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			let group = DispatchGroup()
			group.enter()
			updateRemoteUserData(credential: credential) {
				group.leave()
			}
			
			group.notify(queue: .main) {
				getSessionStatus { status in
					switch status {
					case .signedIn:
						completion(.success(()))
					case .signedOut:
						completion(.failure(SignInError.tokenNotFound))
					}
				}
			}
		}
	}
	
	// MARK: UPDATE USER DATA
	func updateRemoteUserData(credential: AuthCredential, completion: @escaping () -> Void) {
		let provider = AuthenticationProviderType(rawValue: credential.provider)!
		if let currentUser = Auth.auth().currentUser,
		   let user = User(item: currentUser, provider: provider) {
			var email: String?
			var imageUrl: URL?
			
			switch provider {
			case .facebook:
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
			case .google:
				email = user.email
				imageUrl = GIDSignIn
					.sharedInstance
					.currentUser?
					.profile?
					.imageURL(withDimension: UInt(profileImageSize.height))
			}
			
			let updatedUser = User(
				id: user.id,
				displayName: user.displayName,
				email: email,
				imageUrl: imageUrl,
				provider: provider
			)
			
			let userService = UserService()
			userService.setUser(user: updatedUser) { _ in
				completion()
			}
		} else {
			completion()
		}
	}
	
	func verifyDataGovAPIKey(
		apiKey: String,
		completion: @escaping (Bool) -> Void
	) {
		let mediaLibraryService = MediaLibraryService(apiKey: apiKey)
		mediaLibraryService.getAPODList(count: 1) { result in
			switch result {
			case .success(let apodItems):
				completion(!apodItems.isEmpty)
			case .failure:
				completion(false)
			}
		}
	}
}
