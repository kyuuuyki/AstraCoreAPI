//
//  UserService.swift
//  AstraCoreAPI
//

import AstraCoreModels
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public struct UserService: UserServiceProtocol {
	public static var moduleName: String = "AstraCoreAPI.UserService"
	
	let userCollection: CollectionReference
	let userSecretCollection: CollectionReference
	
	public init() {
		var database: DocumentReference!
		let environmentCollection = Firestore.firestore().collection("env")
		switch AstraCoreAPI.coreAPI().environment {
		case .develop:
			database = environmentCollection.document("dev")
		case .staging:
			database = environmentCollection.document("stg")
		case .production:
			database = environmentCollection.document("prod")
		}
		
		self.userCollection = database.collection("users")
		self.userSecretCollection = database.collection("userSecrets")
	}
	
	// MARK: - ADD USER
	public enum AddUserError: Error {
		case dataGovAPIKeyInvalid
	}
	public func addUser(
		user: UserProtocol,
		userSecret: UserSecretProtocol,
		completion: @escaping (Result<UserProtocol, Error>) -> Void
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
				completion(.failure(AddUserError.dataGovAPIKeyInvalid))
				return
			}
			
			userCollection.document(user.id).setData(UserDTO(item: user).toJSON()) { error in
				if let error = error {
					completion(.failure(error))
					return
				}
				
				userSecretCollection.document(user.id).setData(
					UserSecretDTO(item: userSecret).toJSON()
				) { error in
					if let error = error {
						completion(.failure(error))
						return
					}
					completion(.success(user))
				}
			}
		}
	}
	
	// MARK: - GET USER
	public enum GetUserError: Error {
		case notFound
	}
	public func getUser(
		by userId: String,
		completion: @escaping (Result<UserProtocol, Error>) -> Void
	) {
		userCollection.document(userId).getDocument(as: UserDTO.self) { result in
			switch result {
			case .success(let item):
				if let user = User(item: item) {
					completion(.success(user))
				} else {
					completion(.failure(GetUserError.notFound))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	// MARK: - GET USER SECRET
	public enum GetUserSecretError: Error {
		case notFound
	}
	public func getUserSecret(
		by userId: String,
		completion: @escaping (
			Result<UserSecretProtocol, Error>
		) -> Void
	) {
		userSecretCollection.document(userId).getDocument(as: UserSecretDTO.self) { result in
			switch result {
			case .success(let item):
				if let userSecret = UserSecret(item: item) {
					completion(.success(userSecret))
				} else {
					completion(.failure(GetUserSecretError.notFound))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}

extension UserService {
	func updateUser(
		user: UserProtocol,
		completion: @escaping (Result<UserProtocol, Error>) -> Void
	) {
		userCollection.document(user.id).setData(UserDTO(item: user).toJSON()) { error in
			if let error = error {
				completion(.failure(error))
				return
			}
			completion(.success(user))
		}
	}
}

private extension UserService {
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
