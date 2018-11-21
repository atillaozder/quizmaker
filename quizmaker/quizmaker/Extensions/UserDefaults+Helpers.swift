import Foundation

extension UserDefaults {
    
    func set(_ signUp: SignUp) {
        self.set(true, forKey: "isLogged")
        self.set(signUp.id, forKey: "id")
        self.set(signUp.username, forKey: "username")
        self.set(signUp.userType.rawValue, forKey: "type")
        self.setEmail(email: signUp.email)
        self.setFirstname(name: signUp.firstName)
        self.setLastname(name: signUp.lastName)
    }
    
    func set(_ user: EditProfile) {
        self.setEmail(email: user.email)
        self.setFirstname(name: user.firstName)
        self.setLastname(name: user.lastName)
        self.setGender(gender: user.gender)
    }
    
    func getUserType() -> String? {
        return self.string(forKey: "type")
    }
    
    func isLogged() -> Bool {
        return self.bool(forKey: "isLogged")
    }
    
    func getUserIdentifier() -> String? {
        return self.string(forKey: "id")
    }
    
    func setUserIdentifier(userId: String) {
        self.set(userId, forKey: "id")
    }
    
    func getUsername() -> String? {
        return self.string(forKey: "username")
    }
    
    func getPassword() -> String? {
        return self.string(forKey: "password")
    }
    
    func setPassword(password: String) {
        self.set(password, forKey: "password")
    }
    
    func getEmail() -> String? {
        return self.string(forKey: "email")
    }
    
    func setEmail(email: String) {
        self.set(email, forKey: "email")
    }
    
    func getFirstname() -> String? {
        return self.string(forKey: "firstname")
    }
    
    func setFirstname(name: String) {
        self.set(name, forKey: "firstname")
    }
    
    func getLastname() -> String? {
        return self.string(forKey: "lastname")
    }
    
    func setLastname(name: String) {
        self.set(name, forKey: "lastname")
    }
    
    func getGender() -> String? {
        return self.string(forKey: "gender")
    }
    
    func setGender(gender: String) {
        self.set(gender, forKey: "gender")
    }
    
    func logout() {
        self.set(false, forKey: "isLogged")
        self.set(nil, forKey: "id")
    }
}
