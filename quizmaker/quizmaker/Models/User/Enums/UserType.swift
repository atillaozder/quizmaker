
import Foundation

/// An enumeration designated to specify user type.
public enum UserType: String {
    
    /// user is normal
    case normal = "D"
    
    /// user is instructor
    case instructor = "I"
    
    /// user is student
    case student = "S"
    
    /// user is admin
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
