
import Foundation

public enum QuestionType: String {
    case multichoice = "multichoice"
    case truefalse = "truefalse"
    case text = "text"
    
    /// :nodoc:
    var description: String {
        switch self {
        case .multichoice:
            return "Multichoice"
        case .text:
            return "Text"
        case .truefalse:
            return "True False"
        }
    }
}
