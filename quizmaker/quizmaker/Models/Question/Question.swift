
import Foundation

public struct Question: Codable {
    var id: Int
    var question, questionType, answer: String
    var point: Int?
    var quizId: Int?
    var A: String?
    var B: String?
    var C: String?
    var D: String?
    
    init() {
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
    }
    
    enum CodingKeys: String, CodingKey {
        case id, question
        case questionType = "question_type"
        case answer
        case point
        case A
        case B
        case C
        case D
    }
}
