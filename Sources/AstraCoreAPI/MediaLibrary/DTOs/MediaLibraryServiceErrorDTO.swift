//
//  MediaLibraryServiceErrorDTO.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation
import KyuNetworkExtensions
import Moya

struct MediaLibraryServiceErrorDTO: KSPNetworkErrorDecodable, ServiceErrorProtocol {
	// MARK: Protocol Conformance
	var statusCode: Int = 0
	let code: String?
	let message: String?
	
	// MARK: Actual DTO
	var error: MediaLibraryErrorDetailDTO?
	
	// MARK: Initialize
	init(statusCode: Int, code: String?, message: String?) {
		self.statusCode = statusCode
		self.code = code
		self.message = message
	}
	
	init(response: Response?) {
		if let response = response {
			let moyaError = MoyaError.statusCode(response)
			self.init(moyaError: moyaError)
		} else {
			let statusCode = response?.statusCode ?? 0
			self.init(statusCode: statusCode, code: nil, message: nil)
		}
	}
	
	init(moyaError: MoyaError) {
		let statusCode = moyaError.response?.statusCode ?? 0
		let code = "\(moyaError.errorCode)"
		let message = moyaError.errorDescription
		self.init(statusCode: statusCode, code: code, message: message)
	}
}

// MARK: - MediaLibraryServiceErrorDTO
extension MediaLibraryServiceErrorDTO {
	enum CodingKeys: String, CodingKey {
		case error
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.error = try container.decodeIfPresent(
			MediaLibraryErrorDetailDTO.self,
			forKey: .error
		)
		
		self.code = error?.code
		self.message = error?.message
	}
}

// MARK: - MediaLibraryErrorDetailDTO
struct MediaLibraryErrorDetailDTO: Codable {
	let code: String?
	let message: String?
	
	enum CodingKeys: String, CodingKey {
		case code
		case message
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(code, forKey: .code)
		try container.encode(message, forKey: .message)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		code = try container.decodeIfPresent(String.self, forKey: .code)
		message = try container.decodeIfPresent(String.self, forKey: .message)
	}
}
