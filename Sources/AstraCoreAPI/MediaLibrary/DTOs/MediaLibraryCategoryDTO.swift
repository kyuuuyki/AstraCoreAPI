//
//  MediaLibraryCategoryDTO.swift
//  AstraCoreAPI
//

import Foundation
import KyuNetworkExtensions

struct MediaLibraryCategoryDTO: Codable {
	let id: String?
	let title: String?
	let description: String?
	let categoryType: String?
	let link: String?
	let imageUrl: String?
	let key: String?
	let keyType: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case categoryType = "category_type"
		case link
		case imageUrl = "image_url"
		case key
		case keyType = "key_type"
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(description, forKey: .description)
		try container.encode(categoryType, forKey: .categoryType)
		try container.encode(link, forKey: .link)
		try container.encode(imageUrl, forKey: .imageUrl)
		try container.encode(key, forKey: .key)
		try container.encode(keyType, forKey: .keyType)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .id)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		categoryType = try container.decodeIfPresent(String.self, forKey: .categoryType)
		link = try container.decodeIfPresent(String.self, forKey: .link)
		imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
		key = try container.decodeIfPresent(String.self, forKey: .key)
		keyType = try container.decodeIfPresent(String.self, forKey: .keyType)
	}
}
