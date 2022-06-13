//
//  MediaLibraryItemLinkDTO.swift
//  AstraCoreAPI
//

import Foundation
import KyuNetworkExtensions

struct MediaLibraryItemLinkDTO: Codable {
	let href: String?
	let rel: String?
	let render: String?
	
	enum CodingKeys: String, CodingKey {
		case href
		case rel
		case render
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(href, forKey: .href)
		try container.encode(rel, forKey: .rel)
		try container.encode(render, forKey: .render)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		href = try container.decodeIfPresent(String.self, forKey: .href)
		rel = try container.decodeIfPresent(String.self, forKey: .rel)
		render = try container.decodeIfPresent(String.self, forKey: .render)
	}
}
