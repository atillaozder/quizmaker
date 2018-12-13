
import Foundation

public struct Participant: Codable {
    let id: Int
    let username, firstName, lastName, email: String
    let isActive: Bool
    let dateJoined: String
    let userType, gender: String
    let studentID: String?
    
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
