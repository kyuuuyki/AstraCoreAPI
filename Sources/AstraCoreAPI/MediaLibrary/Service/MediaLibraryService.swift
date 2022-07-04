//
//  MediaLibraryService.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuNetworkExtensions
import Moya

public struct MediaLibraryService: MediaLibraryServiceProtocol {
	public static var moduleName: String = "AstraCoreAPI.MediaLibraryService"
	
	let apiKey: String
	let provider: KSPNetworkProvider<
		MediaLibraryAPITarget,
		MediaLibraryServiceErrorDTO
	>
	
	public init(apiKey: String) {
		let authPlugin = AccessTokenPlugin { _ in apiKey }
		let configuration = KSPNetworkConfiguration(stubBehavior: .never, plugins: [authPlugin])
		let provider = KSPNetworkProvider<
			MediaLibraryAPITarget,
			MediaLibraryServiceErrorDTO
		>(
			configuration: configuration,
			configurator: nil
		)
		
		self.apiKey = apiKey
		self.provider = provider
	}
	
	// MARK: - GET APOD
	public enum GetAPODError: Error {
		case notFound
	}
	public func getAPOD(
		date: Date,
		completion: @escaping (
			Result<MediaLibraryAPODItemProtocol, Error>
		) -> Void
	) {
		provider.requestObject(
			type: MediaLibraryAPODItemDTO.self,
			route: .apodByDate(apiKey: apiKey, date: date),
			completion: { result in
				switch result {
				case .success(let item):
					if let item = item, let apodItem = MediaLibraryAPODItem(item: item) {
						completion(.success(apodItem))
					} else {
						completion(.failure(GetAPODError.notFound))
					}
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}
	
	// MARK: - GET APOD LIST
	public func getAPODList(
		count: Int,
		completion: @escaping (
			Result<[MediaLibraryAPODItemProtocol], Error>
		) -> Void
	) {
		provider.requestObjects(
			type: MediaLibraryAPODItemDTO.self,
			route: .apodByCount(apiKey: apiKey, count: count),
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
	
	// MARK: - GET SUGGESTED CATEGORY LIST
	public func getSuggestedCategoryList(
		completion: @escaping (
			Result<[MediaLibraryCategoryProtocol], Error>
		) -> Void
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
	
	// MARK: - GET RECENT MEDIA LIST
	public func getRecentMediaList(
		completion: @escaping (
			Result<[MediaLibraryItemProtocol], Error>
		) -> Void
	) {
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
	
	// MARK: - GET POPULAR MEDIA LIST
	public func getPopularMediaList(
		completion: @escaping (
			Result<[MediaLibraryItemProtocol], Error>
		) -> Void
	) {
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
	
	// MARK: - GET MEDIA LIST NY KEYWORD
	public func getMediaListByKeyword(
		keyword: String,
		page: Int?,
		completion: @escaping (
			Result<[MediaLibraryItemProtocol], Error>
		) -> Void
	) {
		provider.requestObjects(
			type: MediaLibraryItemDTO.self,
			nestedAt: "collection.items",
			route: .search(keyword: keyword, page: page),
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
	
	// MARK: - GET ASSET LIST BY MEDIA ID
	public func getAssetListByMediaID(
		id: String,
		completion: @escaping (
			Result<[MediaLibraryAssetItemProtocol], Error>
		) -> Void
	) {
		provider.requestObjects(
			type: MediaAssetItemDTO.self,
			nestedAt: "collection.items",
			route: .asset(nasaId: id),
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
