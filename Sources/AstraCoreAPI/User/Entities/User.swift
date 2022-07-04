//
//  User.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Firebase
import Foundation

struct User: UserProtocol {
	var id: String
	var displayName: String?
	var email: String?
	var imageUrl: URL?
	var provider: AuthenticationProviderType
	
	init(
		id: String,
		displayName: String?,
		email: String?,
		imageUrl: URL?,
		provider: AuthenticationProviderType
	) {
		self.id = id
		self.displayName = displayName
		self.email = email
		self.imageUrl = imageUrl
		self.provider = provider
	}
	
	init?(item: UserDTO) {
		guard let id = item.id, let provider = item.provider else { return nil }
		self.id = id
		self.displayName = item.displayName
		self.email = item.email
		self.imageUrl = item.imageUrl
		self.provider = AuthenticationProviderType(rawValue: provider)!
	}
	
	init?(item: FirebaseAuth.User, provider: AuthenticationProviderType) {
		self.id = item.uid
		self.displayName = item.displayName
		self.email = item.email
		self.imageUrl = item.photoURL
		self.provider = provider
	}
}
