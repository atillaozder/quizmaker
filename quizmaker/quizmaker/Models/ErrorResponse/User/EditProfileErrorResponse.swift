
import Foundation

/// :nodoc:
public struct EditProfileErrorResponse {
    let firstName: [String]?
    let lastName: [String]?
    let email: [String]?
    let gender: [String]?
}

/// :nodoc:
extension EditProfileErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        email = try container.decodeIfPresent([String].self, forKey: .email)
        firstName = try container.decodeIfPresent([String].self, forKey: .firstName)
        lastName = try container.decodeIfPresent([String].self, forKey: .lastName)
        gender = try container.decodeIfPresent([String].self, forKey: .gender)
    }
}
