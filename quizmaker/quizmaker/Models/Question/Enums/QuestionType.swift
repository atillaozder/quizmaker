
import Foundation

/// An enumeration designated to specify question type.
public enum QuestionType: String {
    
    /// question is multichoice.
    case multichoice = "multichoice"
    
    /// question is truefalse.
    case truefalse = "truefalse"
    
    /// question is text.
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
