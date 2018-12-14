
import Foundation

public enum UserType: String {
    case normal = "D"
    case instructor = "I"
    case student = "S"
    case admin = "A"
    
    /// :nodoc:
    var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .instructor:
            return "Instructor"
        case .student:
            return "Student"
        case .admin:
            return "Admin"
        }
    }
}
