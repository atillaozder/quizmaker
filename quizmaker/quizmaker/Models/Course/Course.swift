
import Foundation

/// A struct that holds course informations.
public struct Course: Codable {
    
    /// Holds course id.
    let id: Int
    
    /// Holds course owner id.
    let owner: Int
    
    /// Holds instructor name.
    let instructorName: String
    
    /// Holds name of the course.
    let name: String
    
    /// Holds students of the course.
    let students: [User]
    
    /// Holds quizzes of the course.
    let quizzes: [Quiz]
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, owner
        case instructorName = "instructor_name"
        case name, students, quizzes
    }
}
