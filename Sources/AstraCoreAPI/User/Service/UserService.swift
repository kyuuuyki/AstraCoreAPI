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
}

public extension UserService {
	func addUser(
		user: UserProtocol,
		userSecret: UserSecretProtocol,
		completion: @escaping (Result<UserProtocol?, Error>) -> Void
	) {
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
	
	func getUser(by userId: String, completion: @escaping (Result<UserProtocol?, Error>) -> Void) {
		userCollection.document(userId).getDocument(as: UserDTO.self) { result in
			switch result {
			case .success(let item):
				let user = User(item: item)
				completion(.success(user))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	func getUserSecret(
		by userId: String,
		completion: @escaping (Result<UserSecretProtocol?, Error>) -> Void
	) {
		userSecretCollection.document(userId).getDocument(as: UserSecretDTO.self) { result in
			switch result {
			case .success(let item):
				let userSecret = UserSecret(item: item)
				completion(.success(userSecret))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
