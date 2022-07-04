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
	
	init(id: String, displayName: String?, email: String?, imageUrl: URL?) {
		self.id = id
		self.displayName = displayName
		self.email = email
		self.imageUrl = imageUrl
	}
	
	init?(item: UserDTO) {
		guard let id = item.id else { return nil }
		self.id = id
		self.displayName = item.displayName
		self.email = item.email
		self.imageUrl = item.imageUrl
	}
	
	init?(item: FirebaseAuth.User) {
		self.id = item.uid
		self.displayName = item.displayName
		self.email = item.email
		self.imageUrl = item.photoURL
	}
}
