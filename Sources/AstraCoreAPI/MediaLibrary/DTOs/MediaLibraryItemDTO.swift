//
//  MediaLibraryItemDTO.swift
//  AstraCoreAPI
//

import Foundation
import KyuNetworkExtensions

struct MediaLibraryItemDTO: Codable {
	let data: [MediaLibraryItemDataDTO]?
	let href: String?
	let links: [MediaLibraryItemLinkDTO]?
	
	enum CodingKeys: String, CodingKey {
		case data
		case href
		case links
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(data, forKey: .data)
		try container.encode(href, forKey: .href)
		try container.encode(links, forKey: .links)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		data = try container.decodeIfPresent([MediaLibraryItemDataDTO].self, forKey: .data)
		href = try container.decodeIfPresent(String.self, forKey: .href)
		links = try container.decodeIfPresent([MediaLibraryItemLinkDTO].self, forKey: .links)
	}
}

struct MediaAssetItemDTO: Codable {
	let href: String?
	
	enum CodingKeys: String, CodingKey {
		case href
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(href, forKey: .href)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		href = try container.decodeIfPresent(String.self, forKey: .href)
	}
}
