import Foundation
import UIKit

final class AlertPresenter {
    func showAlert(from viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}

