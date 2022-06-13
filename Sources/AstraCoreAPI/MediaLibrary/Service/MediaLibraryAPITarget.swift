//
//  MediaLibraryAPITarget.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuNetworkExtensions
import Moya

enum MediaLibraryAPITarget {
	case apodByDate(apiKey: String, date: Date)
	case apodByCount(apiKey: String, count: Int)
	case suggestedCategories
	case recent
	case popular
	case search(keyword: String, page: Int?)
	case asset(nasaId: String)
}

extension MediaLibraryAPITarget: TargetType {
	var baseURL: URL {
		switch self {
		case .apodByDate, .apodByCount:
			return URL(string: "https://api.nasa.gov")!
		case .suggestedCategories:
			return URL(string: "https://gist.githubusercontent.com")!
		case .recent, .popular:
			return URL(string: "https://images-assets.nasa.gov")!
		case .search, .asset:
			return URL(string: "https://images-api.nasa.gov")!
		}
	}
	
	var path: String {
		switch self {
		case .apodByDate, .apodByCount:
			return "/planetary/apod"
		case .suggestedCategories:
			return "/kyuuuyki/f31b8b9c33cdd59c4c3537ecc5de551c/raw/18be4321a1e854ec11af6358649a9315ed5efd42/AstraCoreAPI_suggested_categories.json"// swiftlint:disable:this line_length
		case .recent:
			return "/recent.json"
		case .popular:
			return "/popular.json"
		case .search:
			return "/search"
		case .asset(let nasaId):
			return "/asset/" + nasaId
		}
	}
	
	var headers: [String: String]? {
		return nil
	}
	
	var method: Moya.Method {
		switch self {
		case .apodByDate, .apodByCount, .suggestedCategories, .recent, .popular, .search, .asset:
			return .get
		}
	}
	
	var sampleData: Data {
		return Data()
	}
	
	var task: Task {
		switch self {
		case .apodByDate(let apiKey, let date):
			let parameters = [
				"api_key": apiKey,
				"date": String(date: date, format: "yyyy-MM-dd")
			]
			return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
		case .apodByCount(let apiKey, let count):
			let parameters = [
				"api_key": apiKey,
				"count": min(count, 100)
			] as [String: Any]
			return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
		case .suggestedCategories, .recent, .popular, .asset:
			return .requestPlain
		case .search(let keyword, let page):
			let parameters = [
				"q": keyword,
				"page": page ?? 1
			] as [String: Any]
			return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
		}
	}
}
