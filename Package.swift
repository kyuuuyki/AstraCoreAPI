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
			url: "https://github.com/firebase/firebase-ios-sdk.git",
			from: "9.2.0"
		),
		.package(
			url: "https://github.com/google/GoogleSignIn-iOS.git",
			from: "6.2.0"
		),
		.package(
			url: "https://github.com/facebook/facebook-ios-sdk.git",
			from: "14.0.0"
		)
	],
	targets: [
		.target(
			name: "AstraCoreAPI",
			dependencies: [
				"AstraCoreModels",
				"KyuNetworkExtensions",
				.product(
					name: "FirebaseAuth",
					package: "firebase-ios-sdk"
				),
				.product(
					name: "FirebaseCrashlytics",
					package: "firebase-ios-sdk"
				),
				.product(
					name: "FirebaseFirestoreSwift",
					package: "firebase-ios-sdk"
				),
				.product(
					name: "GoogleSignIn",
					package: "GoogleSignIn-iOS"
				),
				.product(
					name: "FacebookLogin",
					package: "facebook-ios-sdk"
				),
			]
		),
		.testTarget(
			name: "AstraCoreAPITests",
			dependencies: ["AstraCoreAPI"]
		),
	]
)
