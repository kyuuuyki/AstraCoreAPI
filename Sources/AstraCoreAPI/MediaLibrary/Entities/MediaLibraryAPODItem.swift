//
//  MediaLibraryAPODItem.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuGenericExtensions

struct MediaLibraryAPODItem: MediaLibraryAPODItemProtocol {
	let date: Date
	let title: String
	let description: String?
	let imageUrl: URL
	let imageHDUrl: URL?
	let link: URL?
	let mediaType: MediaLibraryMediaType
	
	init?(item: MediaLibraryAPODItemDTO) {
		guard let dateString = item.date,
			  let date = Date(string: dateString, format: "yyyy-MM-dd")
		else {
			return nil
		}
		
		guard let urlString = item.url,
			  let encodedUrlString = urlString.addingPercentEncoding(
				withAllowedCharacters: .urlQueryAllowed
			  ),
			  let url = URL(string: encodedUrlString)
		else {
			return nil
		}
		
		self.date = date
		self.title = item.title ?? ""
		self.description = item.explanation
		self.imageUrl = url
		self.imageHDUrl = URL(string: item.hdurl ?? "")
		self.link = URL(string: "https://apod.nasa.gov/")
		self.mediaType = MediaLibraryMediaType(rawValue: item.mediaType ?? "") ?? .image
	}
}
