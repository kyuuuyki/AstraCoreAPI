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
	
	// MARK: - SET USER
	public func setUser(
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
	
	// MARK: - GET USER
	public enum GetUserError: Error {
		case notFound
	}
	public func getUser(
		by userID: String,
		completion: @escaping (Result<UserProtocol, Error>) -> Void
	) {
		userCollection.document(userID).getDocument(as: UserDTO.self) { result in
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
	
	// MARK: - DELETE USER
	public func deleteUser(
		by userID: String,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		userCollection.document(userID).delete { error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
	}
	
	// MARK: - SET USER SECRET
	public func setUserSecret(
		userSecret: UserSecretProtocol,
		completion: @escaping (Result<UserSecretProtocol, Error>) -> Void
	) {
		userSecretCollection.document(userSecret.id).setData(
			UserSecretDTO(item: userSecret).toJSON()
		) { error in
			if let error = error {
				completion(.failure(error))
				return
			}
			completion(.success(userSecret))
		}
	}
	
	// MARK: - GET USER SECRET
	public enum GetUserSecretError: Error {
		case notFound
	}
	public func getUserSecret(
		by userID: String,
		completion: @escaping (
			Result<UserSecretProtocol, Error>
		) -> Void
	) {
		userSecretCollection.document(userID).getDocument(as: UserSecretDTO.self) { result in
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
	
	// MARK: - DELETE USER SECRET
	public func deleteUserSecret(
		by userID: String,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		userSecretCollection.document(userID).delete { error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
	}
}
