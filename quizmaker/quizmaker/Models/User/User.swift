
import Foundation

public struct User: Codable {
    let id: Int
    let username, email, firstName, lastName: String
    let studentID: String?
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case firstName = "first_name"
        case lastName = "last_name"
        case studentID = "student_id"
    }
}
