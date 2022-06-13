//
//  MediaLibraryAssetItem.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuGenericExtensions

struct MediaLibraryAssetItem: MediaLibraryAssetItemProtocol {
	var url: URL
	
	init?(item: MediaAssetItemDTO) {
		guard let urlString = item.href,
			  let encodedUrlString = urlString.addingPercentEncoding(
				withAllowedCharacters: .urlQueryAllowed
			  ),
			  let url = URL(string: encodedUrlString)
		else {
			return nil
		}
		self.url = url
	}
}
