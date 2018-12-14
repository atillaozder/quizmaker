
import Foundation

public enum Gender: String {
    case unspecified = "unspecified"
    case male = "male"
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
