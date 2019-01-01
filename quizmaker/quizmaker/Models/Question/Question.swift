
import Foundation

/// A struct that holds question informations.
public struct Question: Codable {
    
    /// Holds the identifier of the question.
    var id: Int
    
    /// Holds the question text.
    var question: String
    
    /// Holds the question type.
    var questionType: String
    
    /// Holds the correct answer.
    var answer: String
    
    /// Holds the how many point that question has.
    var point: Int?
    
    /// Holds the quiz identifier.
    var quizId: Int?
    
    /// For multichoice question type holds the A.
    var A: String?
    
    /// For multichoice question type holds the B.
    var B: String?
    
    /// For multichoice question type holds the C.
    var C: String?
    
    /// For multichoice question type holds the D.
    var D: String?

    /// :nodoc:
    var questionNumber: Int?
    
    /// :nodoc:
    var number: String {
        if let n = questionNumber {
            return "\(n)"
        }
        
        return ""
    }
    
    /// :nodoc:
    public init() {
        id = 0
        question = ""
        questionType = ""
        answer = ""
        point = nil
        quizId = nil
        A = nil
        B = nil
        C = nil
        D = nil
        questionNumber = nil
    }
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, question
        case questionType = "question_type"
        case answer
        case point
        case A
        case B
        case C
        case D
        case questionNumber = "question_number"
    }
}
