

import Foundation

/// :nodoc:
public struct RegisterErrorResponse {
    let username: [String]?
    let password: [String]?
    let firstName: [String]?
    let lastName: [String]?
    let studentId: [String]?
    let email: [String]?
}

/// :nodoc:
extension RegisterErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case username
        case password
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case studentId = "non_field_errors"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decodeIfPresent([String].self, forKey: .username)
        password = try container.decodeIfPresent([String].self, forKey: .password)
        email = try container.decodeIfPresent([String].self, forKey: .email)
        firstName = try container.decodeIfPresent([String].self, forKey: .firstName)
        lastName = try container.decodeIfPresent([String].self, forKey: .lastName)
        studentId = try container.decodeIfPresent([String].self, forKey: .studentId)
    }
}
