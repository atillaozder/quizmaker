
import Foundation

/// A struct that holds quiz participant informations.
public struct Participant: Codable {
    
    /// Holds the participant id.
    let id: Int
    
    /// Holds the participant username.
    let username: String
    
    /// Holds the participant first name.
    let firstName: String
    
    /// Holds the participant last name.
    let lastName: String
    
    /// Holds the participant email.
    let email: String
    
    /// Holds the participant is active status whether it is deleted or not.
    let isActive: Bool
    
    /// Holds the participant register date.
    let dateJoined: String
    
    /// Holds the participant type (student, or user).
    let userType: String
    
    /// Holds the participant gender.
    let gender: String
    
    /// Holds the participant student id.
    let studentID: String?
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case studentID = "student_id"
        case isActive = "is_active"
        case dateJoined = "date_joined"
        case userType = "user_type"
        case gender
    }
}
