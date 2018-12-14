
import Foundation

/// An enumeration designated to specify gender.
public enum Gender: String {
    
    /// user has not set gender yet or does not want to specify.
    case unspecified = "unspecified"
    
    /// user is male.
    case male = "male"
    
    /// user is female.
    case female = "female"
    
    /// :nodoc:
    var description: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}
