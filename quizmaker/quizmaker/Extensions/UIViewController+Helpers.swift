
import UIKit

extension UIViewController {
    
    /**
     Opens a popup dialog and if the given message is not empty shows the message, otherwise it opens the popup dialog with dynamic message for example an error occupied.
     
     - Parameters:
        - message: An error message that will be showed in popup dialog.
     
     - Postcondition:
     After completing this method a pop up will occur at the middle of the screen.
     */
    func showErrorAlert(message: String? = nil) {
        let title = "Opps"
        let defaultMessage = "We're sorry. An error occupied. Please try again later."
        let alertController = UIAlertController(title: title, message: message ?? defaultMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Opens a popup dialog that will gives feedback to user after he calls a function that changes the content of the system. For example when the user updates his quiz it opens a pop up dialog saying quiz is updated successfully.
     
     - Parameters:
        - message: A text message that gives feedback to user about intended action.
     
     - Precondition: `message` must be non-nil
     
     - Postcondition:
     After completing this method a pop up will occur at the middle of the screen.
     
     */
    func showDismissAlert(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
