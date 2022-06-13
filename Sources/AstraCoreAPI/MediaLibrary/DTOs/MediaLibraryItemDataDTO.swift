//
//  MediaLibraryItemDataDTO.swift
//  AstraCoreAPI
//

import Foundation
import KyuNetworkExtensions

struct MediaLibraryItemDataDTO: Codable {
	let center: String?
	let dateCreated: String?
	let description: String?
	let keywords: [String]?
	let mediaType: String?
	let nasaId: String?
	let title: String?
	
	enum CodingKeys: String, CodingKey {
		case center
		case dateCreated = "date_created"
		case description
		case keywords
		case mediaType = "media_type"
		case nasaId = "nasa_id"
		case title
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(center, forKey: .center)
		try container.encode(dateCreated, forKey: .dateCreated)
		try container.encode(description, forKey: .description)
		try container.encode(keywords, forKey: .keywords)
		try container.encode(mediaType, forKey: .mediaType)
		try container.encode(nasaId, forKey: .nasaId)
		try container.encode(title, forKey: .title)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		center = try container.decodeIfPresent(String.self, forKey: .center)
		dateCreated = try container.decodeIfPresent(String.self, forKey: .dateCreated)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		keywords = try container.decodeIfPresent([String].self, forKey: .keywords)
		mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
		nasaId = try container.decodeIfPresent(String.self, forKey: .nasaId)
		title = try container.decodeIfPresent(String.self, forKey: .title)
	}
}
