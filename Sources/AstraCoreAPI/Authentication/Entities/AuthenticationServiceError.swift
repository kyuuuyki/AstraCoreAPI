//
//  AuthenticationServiceError.swift
//  AstraCoreAPI
//

import AstraCoreModels
import Foundation

struct AuthenticationServiceError: ServiceErrorProtocol {
	var statusCode: Int
	var code: String?
	var message: String?
}

public protocol AuthenticationUserProtocol {
	var id: String { get }
	var dataGovApiKey: String { get }
}
