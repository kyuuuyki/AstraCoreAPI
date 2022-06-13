//
//  ViewController.swift
//  AstraCoreAPI-Client
//

import AstraCoreAPI
import AstraCoreModels
import UIKit

class ViewController: UIViewController {
	@IBOutlet private weak var textView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let apiKey = "DEMO_KEY"
		AstraCoreAPI.coreAPI().authenticationService().signIn(apiKey: apiKey) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
				self.fetchData()
			case .failure(let error):
				self.handlerError(error: error)
			}
		}
	}
}

private extension ViewController {
	func fetchData() {
		textView.text = ""
		textView.contentInset.left = 16
		textView.contentInset.right = 16
		
		let mediaLibraryService = AstraCoreAPI.coreAPI().mediaLibraryService()
		mediaLibraryService.astromonyPictureOfTheDay(count: 1) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let items):
				self.textView.text = String(describing: items)
			case .failure(let error):
				self.handlerError(error: error)
			}
		}
	}
	
	func handlerError(error: Error) {
		if let error = error as? ServiceErrorProtocol {
			var errorMessage = "Status Code: " + "\(error.statusCode)"
			errorMessage += "\nCode: " + (error.code ?? "-")
			errorMessage += "\nMessage: " + (error.message ?? "-")
			self.textView.text = errorMessage
		} else {
			self.textView.text = error.localizedDescription
		}
	}
}
