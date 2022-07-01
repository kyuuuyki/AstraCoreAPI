//
//  UserSecretDTO.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation

struct UserSecretDTO: Codable {
	var id: String?
	var dataGovAPIKey: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case dataGovAPIKey
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(dataGovAPIKey, forKey: .dataGovAPIKey)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .id)
		dataGovAPIKey = try container.decodeIfPresent(String.self, forKey: .dataGovAPIKey)
	}
	
	init(item: UserSecretProtocol) {
		self.id = item.id
		self.dataGovAPIKey = item.dataGovAPIKey
	}
}
