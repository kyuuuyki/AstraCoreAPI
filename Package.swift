// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AstraCoreAPI",
	platforms: [
		.iOS(.v15)
	],
	products: [
		.library(
			name: "AstraCoreAPI",
			targets: ["AstraCoreAPI"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/kyuuuyki/AstraCoreModels.git",
			branch: "main"
		),
		.package(
			url: "https://github.com/kyuuuyki/KyuNetworkExtensions.git",
			branch: "main"
		),
		.package(
			url: "https://github.com/evgenyneu/keychain-swift.git",
			from: "20.0.0"
		),
		.package(
			url: "https://github.com/firebase/firebase-ios-sdk.git",
			from: "8.10.0"
		),
	],
	targets: [
		.target(
			name: "AstraCoreAPI",
			dependencies: [
				"AstraCoreModels",
				"KyuNetworkExtensions",
				.product(
					name: "KeychainSwift",
					package: "keychain-swift"
				),
				.product(
					name: "FirebaseAnalytics",
					package: "firebase-ios-sdk"
				),
				.product(
					name: "FirebaseAuth",
					package: "firebase-ios-sdk"
				),
				.product(
					name: "FirebaseCrashlytics",
					package: "firebase-ios-sdk"
				),
			]
		),
		.testTarget(
			name: "AstraCoreAPITests",
			dependencies: ["AstraCoreAPI"]
		),
	]
)
