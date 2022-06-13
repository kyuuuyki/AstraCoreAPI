//
//  MediaLibraryItem.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuGenericExtensions

struct MediaLibraryItem: MediaLibraryItemProtocol {
	var id: String
	var title: String
	var description: String
	var imageUrl: URL?
	var link: URL?
	var center: String
	var keywords: [String]
	var createdAt: Date
	var mediaType: MediaLibraryMediaType
	
	init?(item: MediaLibraryItemDTO) {
		guard let data = item.data?.first, let id = data.nasaId else { return nil }
		
		self.id = id
		self.title = data.title ?? ""
		self.description = data.description ?? ""
		
		if let imageUrlString = item.links?.first(where: { $0.render == "image" })?.href,
		   let encodedImageUrlString = imageUrlString.addingPercentEncoding(
			withAllowedCharacters: .urlQueryAllowed
		   ) {
			self.imageUrl = URL(string: encodedImageUrlString)
		}
		
		let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		if let encodedId = encodedId,
		   let url = URL(string: "https://images.nasa.gov/details-\(encodedId)") {
			self.link = url
		}
		
		self.center = data.center ?? ""
		self.keywords = data.keywords ?? []
		
		if let dateString = data.dateCreated,
		   let date = Date(string: dateString, format: "yyyy-MM-dd'T'hh:mm:ss'Z'") {
			self.createdAt = date
		} else {
			self.createdAt = Date()
		}
		
		self.mediaType = MediaLibraryMediaType(rawValue: data.mediaType ?? "") ?? .image
	}
}
