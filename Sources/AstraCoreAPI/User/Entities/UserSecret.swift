//
//  UserSecret.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation

struct UserSecret: UserSecretProtocol {
	var id: String
	var dataGovAPIKey: String
	
	init?(item: UserSecretDTO) {
		guard let id = item.id else { return nil }
		
		self.id = id
		self.dataGovAPIKey = item.dataGovAPIKey ?? "DEMO_KEY"
	}
}
