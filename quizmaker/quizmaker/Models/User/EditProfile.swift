
import Foundation

/// A struct that holds profile information of the logged user if he/she request to edit profile.
public struct EditProfile {
    
    /// holds firstname of the user.
    let firstName: String
    
    /// holds last name of the user.
    let lastName: String
    
    /// holds email of the user.
    let email: String
    
    /// holds gender of the user.
    let gender: String
    
    /**
     Constructor of the class
     
     - Parameters:
        - firstname: First name of the user.
        - lastname: Last name of the user.
        - email: Email of the user.
        - gender: Gender of the user.
     
     - Precondition: `firstname` must be non-nil.
     - Precondition: `lastname` must be non-nil.
     - Precondition: `gender` must be non-nil.
     - Precondition: `email` must be non-nil.
     
     - Postcondition: An object will be created.
     */
    init(firstname: String, lastname: String, email: String, gender: String) {
        self.firstName = firstname
        self.lastName = lastname
        self.email = email
        self.gender = gender
    }
}

/// :nodoc:
extension EditProfile: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case firstname = "first_name"
        case lastname = "last_name"
        case email
        case gender
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        firstName = try container.decode(String.self, forKey: .firstname)
        lastName = try container.decode(String.self, forKey: .lastname)
        email = try container.decode(String.self, forKey: .email)
        gender = try container.decode(String.self, forKey: .gender)
    }
    
}
