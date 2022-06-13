//
//  MediaLibraryService.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuNetworkExtensions
import Moya

struct MediaLibraryService {
	let apiKey: String
	let provider: KSPNetworkProvider<
		MediaLibraryAPITarget,
		MediaLibraryServiceErrorDTO
	>
	
	init(apiKey: String) {
		let authPlugin = AccessTokenPlugin { _ in apiKey }
		let configuration = KSPNetworkConfiguration(stubBehavior: .never, plugins: [authPlugin])
		
		self.apiKey = apiKey
		self.provider = KSPNetworkProvider<
			MediaLibraryAPITarget,
			MediaLibraryServiceErrorDTO
		>(
			configuration: configuration,
			configurator: nil
		)
	}
}

extension MediaLibraryService: MediaLibraryServiceProtocol {
	func astromonyPictureOfTheDay(
		date: Date,
		completion: @escaping (Result<MediaLibraryAPODItemProtocol?, Error>) -> Void
	) {
		provider.requestObject(
			type: MediaLibraryAPODItemDTO.self,
			route: .apodByDate(apiKey: apiKey, date: date),
			responseHandler: { response in
				AstraCoreAPI.coreAPI().updateRateLimitRemaining(response: response)
			},
			completion: { result in
				switch result {
				case .success(let item):
					if let item = item {
						completion(.success(MediaLibraryAPODItem(item: item)))
					} else {
						completion(.success(nil))
					}
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}
	
	func astromonyPictureOfTheDay(
		count: Int,
		completion: @escaping (Result<[MediaLibraryAPODItemProtocol], Error>) -> Void
	) {
		provider.requestObjects(
			type: MediaLibraryAPODItemDTO.self,
			route: .apodByCount(apiKey: apiKey, count: count),
			responseHandler: { response in
				AstraCoreAPI.coreAPI().updateRateLimitRemaining(response: response)
			},
			completion: { result in
				switch result {
				case .success(let items):
					var apodItems = [MediaLibraryAPODItem]()
					for item in items ?? [] {
						if let apodItem = MediaLibraryAPODItem(item: item) {
							apodItems.append(apodItem)
						}
					}
					completion(.success(apodItems))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}
	
	func suggestedCategories(
		completion: @escaping (Result<[MediaLibraryCategoryProtocol], Error>) -> Void
	) {
		provider.requestObjects(
			type: MediaLibraryCategoryDTO.self,
			route: .suggestedCategories
		) { result in
			switch result {
			case .success(let items):
				var categories = [MediaLibraryCategoryProtocol]()
				for item in items ?? [] {
					if let category = MediaLibraryCategory(item: item) {
						categories.append(category)
					}
				}
				completion(.success(categories))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	func recent(completion: @escaping (Result<[MediaLibraryItemProtocol], Error>) -> Void) {
		provider.requestObjects(
			type: MediaLibraryItemDTO.self,
			nestedAt: "collection.items",
			route: .recent
		) { result in
			switch result {
			case .success(let items):
				var ivlItems = [MediaLibraryItem]()
				for item in items ?? [] {
					if let ivlItem = MediaLibraryItem(item: item) {
						ivlItems.append(ivlItem)
					}
				}
				completion(.success(ivlItems.sorted(by: { $0.createdAt > $1.createdAt })))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	func popular(completion: @escaping (Result<[MediaLibraryItemProtocol], Error>) -> Void) {
		provider.requestObjects(
			type: MediaLibraryItemDTO.self,
			nestedAt: "collection.items",
			route: .popular
		) { result in
			switch result {
			case .success(let items):
				var ivlItems = [MediaLibraryItem]()
				for item in items ?? [] {
					if let ivlItem = MediaLibraryItem(item: item) {
						ivlItems.append(ivlItem)
					}
				}
				completion(.success(ivlItems))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	func search(
		keyword: String,
		page: Int?,
		completion: @escaping (Result<[MediaLibraryItemProtocol], Error>) -> Void
	) {
		provider.requestObjects(
			type: MediaLibraryItemDTO.self,
			nestedAt: "collection.items",
			route: .search(keyword: keyword, page: page),
			responseHandler: { response in
				AstraCoreAPI.coreAPI().updateRateLimitRemaining(response: response)
			},
			completion: { result in
				switch result {
				case .success(let items):
					var ivlItems = [MediaLibraryItem]()
					for item in items ?? [] {
						if let ivlItem = MediaLibraryItem(item: item) {
							ivlItems.append(ivlItem)
						}
					}
					completion(.success(ivlItems))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}
	
	func asset(
		id: String,
		completion: @escaping (Result<[MediaLibraryAssetItemProtocol], Error>) -> Void
	) {
		provider.requestObjects(
			type: MediaAssetItemDTO.self,
			nestedAt: "collection.items",
			route: .asset(nasaId: id),
			responseHandler: { response in
				AstraCoreAPI.coreAPI().updateRateLimitRemaining(response: response)
			},
			completion: { result in
				switch result {
				case .success(let items):
					var assetItems = [MediaLibraryAssetItem]()
					for item in items ?? [] {
						if let assetItem = MediaLibraryAssetItem(item: item) {
							assetItems.append(assetItem)
						}
					}
					completion(.success(assetItems))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}
}
