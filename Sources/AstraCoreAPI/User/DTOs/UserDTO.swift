//
//  UserDTO.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation

struct UserDTO: Codable {
	var id: String?
	
	enum CodingKeys: String, CodingKey {
		case id
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .id)
	}
	
	init(item: UserProtocol) {
		self.id = item.id
	}
}
