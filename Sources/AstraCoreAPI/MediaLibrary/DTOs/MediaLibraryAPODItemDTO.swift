//
//  MediaLibraryAPODItemDTO.swift
//  AstraCoreAPI
//

import Foundation
import KyuNetworkExtensions

struct MediaLibraryAPODItemDTO: Codable {
	let date: String?
	let explanation: String?
	let hdurl: String?
	let mediaType: String?
	let serviceVersion: String?
	let title: String?
	let url: String?
	
	enum CodingKeys: String, CodingKey {
		case date
		case explanation
		case hdurl
		case mediaType = "media_type"
		case serviceVersion = "service_version"
		case title
		case url
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(date, forKey: .date)
		try container.encode(explanation, forKey: .explanation)
		try container.encode(hdurl, forKey: .hdurl)
		try container.encode(mediaType, forKey: .mediaType)
		try container.encode(serviceVersion, forKey: .serviceVersion)
		try container.encode(title, forKey: .title)
		try container.encode(url, forKey: .url)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		date = try container.decodeIfPresent(String.self, forKey: .date)
		explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
		hdurl = try container.decodeIfPresent(String.self, forKey: .hdurl)
		mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
		serviceVersion = try container.decodeIfPresent(String.self, forKey: .serviceVersion)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		url = try container.decodeIfPresent(String.self, forKey: .url)
	}
}
