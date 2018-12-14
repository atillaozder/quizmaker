
import Foundation

public struct Course: Codable {
    let id, owner: Int
    let instructorName, name: String
    let students: [User]
    let quizzes: [Quiz]
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, owner
        case instructorName = "instructor_name"
        case name, students, quizzes
    }
}
