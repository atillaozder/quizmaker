
import Foundation

extension UserDefaults {
    
    /// :nodoc:
    func set(_ user: SignUp) {
        self.set(true, forKey: "isLogged")
        self.set(user.id, forKey: "id")
        self.set(user.username, forKey: "username")
        self.set(user.userType.rawValue, forKey: "type")
        self.setEmail(email: user.email)
        self.setFirstname(name: user.firstName)
        self.setLastname(name: user.lastName)
        self.synchronize()
    }
    
    /// :nodoc:
    func set(_ user: EditProfile) {
        self.setEmail(email: user.email)
        self.setFirstname(name: user.firstName)
        self.setLastname(name: user.lastName)
        self.setGender(gender: user.gender)
        self.synchronize()
    }
    
    /// :nodoc:
    func getUserType() -> String? {
        return self.string(forKey: "type")
    }
    
     /**
     Controls if the user is logged into the system by checking defaults.
     
     - Returns: true or false
    
     */
    func isLogged() -> Bool {
        return self.bool(forKey: "isLogged")
    }
    
    /// :nodoc:
    func getUserIdentifier() -> Int? {
        return self.integer(forKey: "id")
    }
    
    /// :nodoc:
    func setUserIdentifier(userId: Int) {
        self.set(userId, forKey: "id")
    }
    
    /// :nodoc:
    func getUsername() -> String? {
        return self.string(forKey: "username")
    }
    
    /// :nodoc:
    func getPassword() -> String? {
        return self.string(forKey: "password")
    }
    
    /// :nodoc:
    func setPassword(password: String) {
        self.set(password, forKey: "password")
    }
    
    /// :nodoc:
    func getEmail() -> String? {
        return self.string(forKey: "email")
    }
    
    /// :nodoc:
    func setEmail(email: String) {
        self.set(email, forKey: "email")
    }
    
    /// :nodoc:
    func getFirstname() -> String? {
        return self.string(forKey: "firstname")
    }
    
    /// :nodoc:
    func setFirstname(name: String) {
        self.set(name, forKey: "firstname")
    }
    
    /// :nodoc:
    func getLastname() -> String? {
        return self.string(forKey: "lastname")
    }
    
    /// :nodoc:
    func setLastname(name: String) {
        self.set(name, forKey: "lastname")
    }
    
    /// :nodoc:
    func getGender() -> String? {
        return self.string(forKey: "gender")
    }
    
    /// :nodoc:
    func setGender(gender: String) {
        self.set(gender, forKey: "gender")
    }
    
    /**
     When the user logs out, it finds all attributes that was saved to defaults and removes each of them. Also, sets isLogged boolean value to false.
     */
    func logout() {
        self.set(false, forKey: "isLogged")
        self.removeObject(forKey: "id")
        self.removeObject(forKey: "gender")
        self.removeObject(forKey: "lastname")
        self.removeObject(forKey: "firstname")
        self.removeObject(forKey: "email")
        self.removeObject(forKey: "password")
        self.removeObject(forKey: "type")
        self.removeObject(forKey: "username")
        self.synchronize()
    }
}
