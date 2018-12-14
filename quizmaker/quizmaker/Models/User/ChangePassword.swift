
import Foundation

/// A struct that holds old, new and confirm password of the logged user if he/she request to change password.
public struct ChangePassword {
    
    /// old password of the user.
    let oldPassword: String
    
    /// new password of the user.
    let newPassword: String
    
    /// confirm password of the user.
    let confirmPassword: String
    
    /**
     Constructor of the class
     
     - Parameters:
        - old: Old password of the user.
        - new: New password of the user.
        - confirm: Confirm password of the user.
     
     - Precondition: `old` must be non-nil.
     - Precondition: `new` must be non-nil.
     - Precondition: `confirm` must be non-nil.
     
     - Postcondition: An object will be created.
     */
    init(old: String, new: String, confirm: String) {
        self.oldPassword = old
        self.newPassword = new
        self.confirmPassword = confirm
    }
}

