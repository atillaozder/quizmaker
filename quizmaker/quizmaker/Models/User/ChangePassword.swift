
import Foundation

public struct ChangePassword {
    let oldPassword: String
    let newPassword: String
    let confirmPassword: String
    
    init(old: String, new: String, confirm: String) {
        self.oldPassword = old
        self.newPassword = new
        self.confirmPassword = confirm
    }
}

