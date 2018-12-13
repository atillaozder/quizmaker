
import Foundation

public struct EditProfile {
    
    let firstName: String
    let lastName: String
    let email: String
    let gender: String
    
    init(firstname: String, lastname: String, email: String, gender: String) {
        self.firstName = firstname
        self.lastName = lastname
        self.email = email
        self.gender = gender
    }
}

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
