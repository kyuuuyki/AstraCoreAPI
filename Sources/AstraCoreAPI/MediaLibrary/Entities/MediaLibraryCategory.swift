//
//  MediaLibraryCategory.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuGenericExtensions

struct MediaLibraryCategory: MediaLibraryCategoryProtocol {
	let id: String
	let title: String
	let description: String?
	let categoryType: MediaLibraryCategoryType?
	let imageUrl: URL
	let link: URL?
	let key: String?
	let keyType: MediaLibraryCategoryKeyType?
	
	init?(item: MediaLibraryCategoryDTO) {
		guard let id = item.id,
			  let imageUrlString = item.imageUrl,
			  let encodedImageUrlString = imageUrlString.addingPercentEncoding(
				withAllowedCharacters: .urlQueryAllowed
			  ),
			  let imageUrl = URL(string: encodedImageUrlString)
		else {
			return nil
		}
		
		self.id = id
		self.title = item.title ?? ""
		self.description = item.description
		self.categoryType = MediaLibraryCategoryType(rawValue: item.categoryType ?? "")
		self.link = URL(string: item.link ?? "")
		self.imageUrl = imageUrl
		self.key = item.key
		self.keyType = MediaLibraryCategoryKeyType(rawValue: item.keyType ?? "")
	}
}
