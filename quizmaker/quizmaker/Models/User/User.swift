
import Foundation

/// A struct that holds user informations.
public struct User: Codable {
    
    /// Holds the user id.
    let id: Int
    
    /// Holds the user username.
    let username: String
    
    /// Holds the user email.
    let email: String
    
    /// Holds the user first name.
    let firstName: String
    
    /// Holds the user last name.
    let lastName: String
    
    /// Holds the user student id.
    let studentID: String?
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case firstName = "first_name"
        case lastName = "last_name"
        case studentID = "student_id"
    }
}
