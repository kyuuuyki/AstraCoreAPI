//
//  User.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Firebase
import Foundation

struct User: UserProtocol {
	var id: String
	
	init?(item: UserDTO) {
		guard let id = item.id else { return nil }
		self.id = id
	}
	
	init?(item: FirebaseAuth.User) {
		self.id = item.uid
	}
}
