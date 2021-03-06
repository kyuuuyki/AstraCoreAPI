//
//  UserDTO.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation

struct UserDTO: Codable {
	var id: String?
	var displayName: String?
	var email: String?
	var imageUrl: URL?
	var provider: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case displayName
		case email
		case imageUrl
		case provider
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(displayName, forKey: .displayName)
		try container.encode(email, forKey: .email)
		try container.encode(imageUrl, forKey: .imageUrl)
		try container.encode(provider, forKey: .provider)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .id)
		displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
		email = try container.decodeIfPresent(String.self, forKey: .email)
		imageUrl = try container.decodeIfPresent(URL.self, forKey: .imageUrl)
		provider = try container.decodeIfPresent(String.self, forKey: .provider)
	}
	
	init(item: UserProtocol) {
		self.id = item.id
		self.displayName = item.displayName
		self.email = item.email
		self.imageUrl = item.imageUrl
		self.provider = item.provider.rawValue
	}
}
